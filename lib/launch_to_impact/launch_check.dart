import 'dart:io';

import 'package:fithome_app/common_code/platform_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import 'install_monitor/appts_model.dart';
import 'install_monitor/monitors_model.dart';
import 'signin/auth_service.dart';

enum UserState { unknown, waitlist, start_training, member }

class LaunchCheck {
  final Logger log = Logger('launch_check.dart');

//****************************************** */
//*If there is no wifi, the app doesn't continue
//*Returns True if the app can access wifi.
//****************************************** */
  Future<bool> isWifi() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        log.info('We can connect to wifi.');
        return true;
      }
    } on SocketException catch (_) {
      log.info('We cannot connect to wifi.');
      return false;
    }
    return true;
  }

//****************************************** */
//*Perhaps the homeowner can connect their phone to wifi.  If so,
//*we provide a way to try to connect.
//****************************************** */
  Future<void> askUserToFixWifi(BuildContext context) async {
    log.info('askUserToFixWifi');
    final tryAgain = await PlatformAlertDialog(
      title: 'Cannot access the Internet',
      content: 'Please check the wifi connection',
      defaultActionText: 'Try Again',
    ).show(context);
    if (tryAgain == true) {
      final bool bIsWifi = await isWifi();
      if (!bIsWifi) {
        await askUserToFixWifi(context);
      }
    }
  }

//****************************************** */
//*Here is where we walk through whether the homeowner is
//*already a member or not.  If not, we start the process of
//*getting homeowner info and setting up an install time for an
//*electrician to come out and install a monitor.
//****************************************** */
  Future<UserState> checkForMembership(BuildContext context) async {
    final auth = Provider.of<AuthBase>(context);
    final monitors = Provider.of<Monitors>(context);
    if (!await isWifi()) {
      await askUserToFixWifi(context);
    }
    log.info('We have access to wifi.  Checking if user is already a member.');
    String _memberUid = await auth.signIn(context);
    if (_memberUid == null) {
      log.info('Homeowner does not have an account.');
      //* Homeowner is not a member yet.  Let's see what the homeowner's next steps
      //* are to become a member.  If there aren't any monitors available, then we
      //* know to take the homeowner to the waitlist page.
      // Check to see if there are available monitors.

      bool availableMonitors = await monitors.checkAvailability();
      // if there is not a monitor available, go to the waitlist page.
      if (!availableMonitors) {
        log.info('No monitor is available.  Sending to waitlist.');
        return UserState.waitlist;
      } else {
        // This means there is a monitor available and the use is not a member.  Go to the start training page.
        log.info('A monitor is available.');
      }
      return UserState.start_training;
    } else {
//* The user is already a member.
      log.info('The user can log in, already a member.');
      return UserState.member;
    }
  }
}
