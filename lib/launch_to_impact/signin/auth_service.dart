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
  /// returns either a Member instance or null if couldn't sign in.
  //**************************************************************************
  Future<String> signIn(BuildContext context,
      {String email, String password}) async {
    FirebaseUser user;
    String _email;
    String _password;
    Member member;
// The call to signIn can be made with or without the email and password.
// It the email and password were not passed in, we'll see if the email
// and password have been stored locally.
    if ((email == null) || (password == null)) {
      log.info('Email and password were not passed in.');
      if (await _isCredsInLocalStore()) {
        log.info('Email and password are in local store.');
        // The local store does contain member info.  The member info it
        // should contain includes the email, password, and member ID.  The
        // member ID is the Firebase account id for this member.
        // Let's get these values.
        member = Member();
        await member.getValues();
        // We need to check if these values will work with Firebases's signinwithemail.
        // Neither the email nor the password can be null.
        // If we have non null values for the email and password, we'll move on to
        // signing into Firebase.
        _email = member.email;
        _password = member.password;
        if (_email == null || _password == null) {
          log.info(
              'The email $_email or the password $_password is null in the local store.  Both have to be non-null.');
          member.clear();
          return null;
        }
        // The email and / or password are not in the local store.  We can't login.
      } else {
        log.info('Email and password are not in local store, member is null.');
        return null;
      }
    }
    // Both the email and password were passed in.  We'll try to sign into Firebase.
    else {
      _email = email;
      _password = password;
    }
    // We've already returned if there are no credentials, so try to sign in.

    try {
      user = await _firebaseAuth.signInWithEmailAndPassword(
          email: _email, password: _password);
    } on PlatformException catch (e) {
      log.info('Sign in failed.  Error: $e');
      // We check ERROR_USER_NOT_FOUND because the email and password in the local store may no longer be connected to a Firebase Account.  If this is the case,
      // we go back to the state where we don't have a way to log the homeowner in.  This means the homeowner needs to fill out the StartTrainingPage so that
      // a new email and password can be stored as well as a Firebase account created.
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
      member.getValues();
      log.info('New email: ${member.email}.  New password: ${member.password}. New member id: ${member.id}');
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
