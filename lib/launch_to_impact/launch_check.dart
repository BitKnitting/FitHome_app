import 'dart:io';

import 'package:fithome_app/common_code/platform_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import 'install_monitor/appts_ model.dart';
import 'signin/auth_service.dart';

enum UserState { unknown, waitlist, start_training, member }

class LaunchCheck {
  final Logger log = Logger('launch_check.dart');

//
//*Returns True if the app can access wifi.
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

  Future<UserState> checkForMembership(BuildContext context) async {
    final appts = Provider.of<Appointments>(context);
    final auth = Provider.of<AuthBase>(context);
    log.info('Checking for membership type.');
    if (!await isWifi()) {
      await askUserToFixWifi(context);
    }
    log.info('We have access to wifi.  Checking if user is already a member.');
    Member member = await auth.signIn(context);
    if (member == null) {
      // User is not a member.
      // Check to see if there are available monitors.
      //*TODO: available monitors check is dummied out for now.
      bool availableMonitors = await _checkMonitorAvailability(member);
      // if there is not a monitor available, go to the waitlist page.
      if (!availableMonitors) {
        log.info('No monitor is available.  Check about waitlist.');
        return UserState.waitlist;
      } else {
        // This means there is a monitor available and the use is not a member.  Go to the start training page.
        log.info('A monitor is available.');
      }
      // Check if there are available appointment times for an electrician to install the monitor.
      await appts.getInstallTimes();
      log.info(
          "Available dates/times for electrician to install monitor: ${appts.installTimes}");
      return UserState.start_training;
    } else {
      // The user is already a member - load the impact page.
      await Future.delayed(Duration(seconds: 2));
      log.info('The user can log in, already a member.');
      return UserState.member;
    }
  }

  Future<bool> _checkMonitorAvailability(Member member) async {
    // The member is signed in, so access the Firebase RT available_monitors node...

    return true;
  }
}
