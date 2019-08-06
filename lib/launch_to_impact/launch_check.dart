import 'dart:io';

import 'package:fithome_app/common_code/platform_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

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
    log.info('Checking for membership type.');
    if (!await isWifi()) {
      await askUserToFixWifi(context);
    }
    log.info('We have access to wifi.  Checking if user is already a member.');
    // if the user is already a member, go to the impact page.
    // if the user is not a member, check if there is a monitor available.
    // if there is not a monitor available, go to the waitlist page.
    // This means there is a monitor available and the use is not a member.  Go to the start training page.
    await Future.delayed(Duration(seconds: 2));
    return UserState.member;
  }
}
