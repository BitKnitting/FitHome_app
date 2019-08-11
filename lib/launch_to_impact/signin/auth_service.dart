import 'package:firebase_auth/firebase_auth.dart';
import 'package:fithome_app/common_code/platform_alert_dialog.dart';
import 'package:fithome_app/common_code/prefs_service.dart';
import 'package:fithome_app/common_code/globals.dart';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:flutter/services.dart';

// By using the Member class, our abstract AuthBase could be built from other authentication dbs.
class Member {
  Member({this.uid}) {
    _saveUid(this.uid);
  }
  final String uid;
  // From https://dart.dev/guides/language/effective-dart/usage
  // If you make a parameter optional but don’t give it a default value,
  // the language implicitly uses null as the default
  String _email;
  String _password;
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
}

//**************************************************************************
// Authentication Provider.
//**************************************************************************

abstract class AuthBase {
  Future<Member> signIn(BuildContext context, {String email, String password});
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
      log.info('email and passwordwere not passed in.');
      if (await _isCredsInLocalStore()) {
        log.info('email and password are in local store.');
        member = Member();
        // The Member get for email and password will retrieve values from shared preferences.
        _email = await member.email;
        _password = await member.password;
        // If we don't have the email and password and they are not in Shared preferences, return
        // null for the member instance.
      } else {
        log.info('email and password are not in local store, member is null.');
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
            'There is an email and password stored locally, but we cannot log into the account db with them, member is null.');
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
      log.info('user is null');
      return null;
    }
    log.info('able to convert Firebase uid to member');
    return Member(uid: user.uid);
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
