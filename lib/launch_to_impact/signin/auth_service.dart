import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fithome_app/common_code/platform_alert_dialog.dart';
import 'package:fithome_app/common_code/prefs_service.dart';
import 'package:fithome_app/common_code/globals.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:flutter/services.dart';

class InstallTimes {
  Map<DateTime, List> _appts = Map<DateTime, List>();
  //**************************************************************************
  // The Map of appointments
  //**************************************************************************
  Future<Map<DateTime, List>> getAppts() async {
    print('appts: $_appts, length: ${_appts.length}');
    // Have we already gotten the appointments?
    if (_appts.length > 0) {
      return _appts;
    }
    DateTime dateTime = DateTime.now();
    await Future.delayed(const Duration(seconds: 2), () {
      _appts = {
        dateTime.add(Duration(days: 2)): ['10:30', '12:30', '13:00'],
        dateTime.add(Duration(days: 20)): ['9:15', '12:15'],
      };
    });
    return _appts;
  }

  get appts async {
    // If the email string is either empty or null, check shared preferences
    // If not, we have already retrieved it (or it does not exist).
    if (_appts?.isEmpty ?? true) {
      return await getAppts();
    }
    return _appts;
  }
}

//*************************************************************************** */
class AvailableMonitors {
  Logger log = Logger('auth_service.dart');
  // AvailableMonitors.fromJson(Map data) {
  //   data.forEach((k, v) => print('$k: $v'));
  //   print('hello');
  // }
  String getMonitor(Map data) {
    // Go through monitors and find one that is available.
    String monitor = '';
    for (String key in data.keys) {
      if (data[key] == true) {
        // Found a free monitor.
        monitor = key;
        break;
      }
    }
    log.info('Got monitor $monitor.');
    return monitor;
  }

  //**************************************************************************
  //* Set the monitor's value to 'false' so it is no longer seen as available.
  //**************************************************************************
  void setUnavailable(String monitor) async {
    try {
      await FirebaseDatabase.instance
          .reference()
          .child('available_monitors')
          .update({monitor: false});
      log.info('Updated $monitor availability to false in Firebase.');
    } catch (e) {
      log.info(
          '!!!Error: ${e.message} On attempting to set monitor $monitor to false in Firebase.!!!');
      return;
    }
  }
}

// By using the Member class, our abstract AuthBase could be built from other authentication dbs.
class Member {
  Member({this.uid}) {
    _saveUid(this.uid);
  }
  Map<String, dynamic> toJson(
          {String address,
          String name,
          String phone,
          String email,
          String monitor}) =>
      {
        "address": address,
        "email": email,
        "monitor": monitor,
        "name": name,
        "phone": phone,
        "status": "start",
        "start_timestamp": {".sv": "timestamp"},
      };
  final String uid;
  // From https://dart.dev/guides/language/effective-dart/usage
  // If you make a parameter optional but don’t give it a default value,
  // the language implicitly uses null as the default
  String _email;
  String _password;

  Logger log = Logger('auth_service.dart');
  //**************************************************************************
  // email property
  //**************************************************************************
  get email async {
    // If the email string is either empty or null, check shared preferences
    // If not, we have already retrieved it (or it does not exist).
    if (_email?.isEmpty ?? true) {
      return await Prefs().getValue(emailKey);
    }
  }

  set email(String emailString) {
    Prefs().setKey(emailKey, emailString);
  }

  //**************************************************************************
  // password property
  //**************************************************************************
  get password async {
    if (_password?.isEmpty ?? true) {
      return await Prefs().getValue(passwordKey);
    }
  }

  set password(String pwd) {
    Prefs().setKey(passwordKey, pwd);
  }

  //**************************************************************************
  // saveUid property
  //**************************************************************************
  Future<void> _saveUid(String uid) async {
    await Prefs().setKey(uidKey, uid);
  }

  //**************************************************************************
  // clear properties from local store.
  //**************************************************************************
  Future<bool> clear() async {
    return await Prefs().clear();
  }

  //**************************************************************************
  // Member has been created, so assign a monitor..
  //*TODO: Send text message to FitHome member services for them to label and config the monitor.
  //**************************************************************************
  Future<String> assignMonitor(BuildContext context) async {
    //Get the list of available_monitors.
    try {
      DataSnapshot availableMonitors = await FirebaseDatabase.instance
          .reference()
          .child('available_monitors')
          .once();
      AvailableMonitors availableMonitor = AvailableMonitors();
      String monitor = availableMonitor.getMonitor(availableMonitors.value);
      if (monitor.isEmpty) {
        return null;
      }
      availableMonitor.setUnavailable(monitor);
      //* Add -<mmddyyyy> to monitor name.
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('MMddyyyy').format(now);
      monitor = monitor + '-' + formattedDate;
      return monitor;
    } catch (e) {
      log.info('Error: ${e.message} .');
      PlatformAlertDialog(
        title: 'Data Access Error!',
        content: '${e.message}',
        defaultActionText: 'OK',
      ).show(context);
      log.info(
          'Error trying to read the available monitors.  Error: ${e.message}');
      //*TODO: Handle when cannot get to the available_monitors list.
      return null;
    }
    //Go through the list and find one that has true as it's value
    //update the monitor to have false in it's value.
    //Create a monitor name that is "<monitor name>-MMDDYYYY"
    //Store monitor name in user record.
  }

  Future<bool> createUserRecord(Map userRecordJson) async {
    // For the member that has the uid, i'm pushing the uid key.
    // Note: I had trouble finding great documentation for Firebase RT.
    // One aspect I found was, push() generates a document id.
    // But set does not. I use set because I'm using the uid as the unique id.
    try {
      await FirebaseDatabase.instance
          .reference()
          .child('members')
          .child(uid)
          .set(userRecordJson);
    } catch (e) {
      log.info('Error: ${e.message} .');
      return false;
    }
    return true;
  }
}

//**************************************************************************
// Authentication Provider.
//*TODO: Probably refactor into a membership provider.
//**************************************************************************

abstract class AuthBase {
  Future<Member> signIn(BuildContext context, {String email, String password});
  Future<Member> createAccount(
      BuildContext context, String email, String password);
}

class Auth implements AuthBase {
  Logger log = Logger('auth_service.dart');
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  //************************************************************************** */
  //**************************************************************************
  // signIn
  // returns either a Member instance or null if couldn't sign in.
  //**************************************************************************
  Future<Member> signIn(BuildContext context,
      {String email, String password}) async {
    FirebaseUser user;
    String _email;
    String _password;
    Member member;

    // If email and password have not been passed in, Shared Prefs is checked to
    // see if they are stored there.  If they are, use these.  If they are not,
    // return a null member.
    // If email and password have been passed in, don't use Shared Prefs.  Try to
    // sign in with these.  If sign in fails, send back a null member.  If it succeeds,
    // We'll store the email and password after a successful sign-in
    if ((email == null) || (password == null)) {
      log.info('Email and password were not passed in.');
      if (await _isCredsInLocalStore()) {
        log.info('Email and password are in local store.');
        member = Member();
        // The Member get for email and password will retrieve values from shared preferences.
        _email = await member.email;
        _password = await member.password;
        // If we don't have the email and password and they are not in Shared preferences, return
        // null for the member instance.
      } else {
        log.info('Email and password are not in local store, member is null.');
        return null;
      }
      // An email and password were passed in.
    } else {
      _email = email;
      _password = password;
    }
    // We've already returned if there are no credentials, so try to sign in.

    try {
      user = await _firebaseAuth.signInWithEmailAndPassword(
          email: _email, password: _password);
    } on PlatformException catch (e) {
      log.info('Sign in failed.  Error: $e');
      if (e.code == 'ERROR_USER_NOT_FOUND') {
        log.info(
            'There is an email and password stored locally, but we cannot log in with them.  Deleting member info from shared preferences.  Member is null.');
        member.clear();
        return null;
      } else {
        log.info('Error: ${e.message}, member is null.');
        PlatformAlertDialog(
          title: 'Sign-in Error!',
          content: '${e.message}',
          defaultActionText: 'OK',
        ).show(context);
        return null;
      }
    }
    return _memberFromFirebase(user);
  }

  //**************************************************************************
  // _isCredsInLocalStore
  // check if the email and password are stored in Shared Preferences.
  //**************************************************************************
  Future<bool> _isCredsInLocalStore() async {
    bool pwdInStore = await Prefs().isInLocalStore(passwordKey);
    bool emailInStore = await Prefs().isInLocalStore(emailKey);
    if (pwdInStore && emailInStore) {
      return true;
    }
    return false;
  }

  //**************************************************************************
  // _memberFromFirebase
  // return a member instance based on the logged in user's Firebase User ID.
  //**************************************************************************
  Member _memberFromFirebase(FirebaseUser user) {
    if (user == null) {
      log.info('The user is null.');
      return null;
    }
    log.info('We are able to convert Firebase uid to member.');
    return Member(uid: user.uid);
  }

  //**************************************************************************
  // createMemberAccount
  // return a member instance based on the logged in user's Firebase User ID.
  //**************************************************************************
  Future<Member> createAccount(
      BuildContext context, String email, String password) async {
    FirebaseUser user;
    try {
      user = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      // Store email and password in shared preferences.
      log.info(
          'We are able to create the account.  Storing info in Shared Preferences.');
      Member().email = email;
      Member().password = password;
      return _memberFromFirebase(user);
    } on PlatformException catch (e) {
      log.info('Error: ${e.message}.  Email: $email Password $password.');
      final memberErrorDlg = await PlatformAlertDialog(
        title: 'Create Member Error!',
        content: '${e.message}',
        defaultActionText: 'OK',
      ).show(context);
      if (memberErrorDlg == true) {
        return null;
      }
    }
    return null;
  }

  //**************************************************************************
  // _createMemberAccount
  // return a member instance based on the logged in user's Firebase User ID.
  //**************************************************************************
  // Future<Member> _createMemberAccount(
  //     BuildContext context, String email, String password) async {
  //   FirebaseUser user;
  //   try {
  //     user = await _firebaseAuth.createUserWithEmailAndPassword(
  //         email: email, password: password);
  //   } on PlatformException catch (e) {
  //     PlatformAlertDialog(
  //       title: 'Create Member Error!',
  //       content: '${e.message}',
  //       defaultActionText: 'OK',
  //     ).show(context);
  //   }
  //   // Store email and password in shared preferences.
  //   log.info(
  //       'We are able to create the account.  Storing email and password in Shared Preferences.');
  //   Member().email = email;
  //   Member().password = password;
  //   return _memberFromFirebase(user);
  // }

  // Future<void> signOut() async {
  //   return await _firebaseAuth.signOut();
  // }
}
