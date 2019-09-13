import 'package:firebase_auth/firebase_auth.dart';
import 'package:fithome_app/common_code/globals.dart';
import 'package:fithome_app/common_code/platform_alert_dialog.dart';
import 'package:fithome_app/common_code/prefs_service.dart';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../member_model.dart';

//**************************************************************************
// Authentication Provider.
//**************************************************************************

abstract class AuthBase {
  Future<String> signIn(BuildContext context, {String email, String password});
  Future<String> createAccount(
      BuildContext context, String email, String password);
}

class Auth implements AuthBase {
  Logger log = Logger('auth_service.dart');
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  //**************************************************************************
  // signIn
  // returns either a Member instance or null if couldn't sign in.
  //**************************************************************************
  Future<String> signIn(BuildContext context,
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

        /// If there are any properties stored in Prefs(), load them up.
        await member.getValues();
        // The Member get for email and password will retrieve values from shared preferences.
        _email = member.email;
        _password = member.password;
        if (_email == null || _password == null) {
          log.info(
              'The local store does not have the correct email and password info to log in.');
          member.clear();
          return null;
        } else {
          log.info(
              'Email and password are not in local store, member is null.');
          return null;
        }
        // An email and password were passed in.
      } else {
        _email = email;
        _password = password;
      }
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
    return user.uid;
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
  // createMemberAccount
  // return the member's uid.
  //**************************************************************************
  Future<String> createAccount(
      BuildContext context, String email, String password) async {
    FirebaseUser user;
    final member = Provider.of<Member>(context);
    try {
      user = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      // Store email, password, Firebase account id in shared preferences.
      log.info(
          'We are able to create the account.  Storing info in Shared Preferences.');
      member.email = email;
      member.password = password;
      await member.saveUid(user.uid);
      log.info('New member id: ${member.id}');
      return user.uid;
    } on PlatformException catch (e) {
      log.severe('Error: ${e.message}.  Email: $email Password $password.');
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
}
