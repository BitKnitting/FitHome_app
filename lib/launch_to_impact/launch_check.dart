import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

enum UserState { unknown, waitlist, start_training, member }
enum WifiState { noWifi, wifi }

class LaunchCheck {
  final Logger log = Logger('launch_check.dart');
  WifiState wifiState = WifiState.noWifi;

//
//*Returns True if the app can access wifi.
  Future<bool> isWifi() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        log.info('We can connect to wifi.');
        wifiState = WifiState.wifi;
        return true;
      }
    } on SocketException catch (_) {
      log.info('We cannot connect to wifi.');
      wifiState = WifiState.noWifi;
      return false;
    }
    wifiState = WifiState.wifi;
    return true;
  }

  void askForWifi(BuildContext context) {
    log.info('in askForWifi');

    Widget okButton = FlatButton(
      child: Text("Try Again"),
      onPressed: () async {
        Navigator.of(context).pop(); // dismiss dialog

        bool bIsWifi = await isWifi();
        if (!bIsWifi) {
          askForWifi(context);
        }
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Where for out thou, wifi?"),
      content: Text("Please check the wifi connection."),
      actions: [
        okButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<UserState> checkForMembership(BuildContext context) async {
    log.info('Checking for membership type.');
    if (!await isWifi()) {
      askForWifi(context);
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
