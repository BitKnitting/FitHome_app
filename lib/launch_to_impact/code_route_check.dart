import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import 'signin/auth_service.dart';

enum WhichPage { noWiFi, startTraining, waitingList, impact }

class RouteCheck {
  final Logger log = Logger('code_route_check.dart');
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

  Future<bool> isMonitorAvailable() async {
    log.info('monitor is not available');
    return false;
  }

  Future<WhichPage> checkWhichPageToBuild(BuildContext context) async {
    final auth = Provider.of<AuthBase>(context);
    //* Is wifi available?
    if (!await isWifi()) {
      return WhichPage.noWiFi;
    }
    // wifi is available.  On to the next check.
    //
    //* Does the app user have local creds that log them in?
    Member member = await auth.signIn(context);
    if (member == null) {
      // the app user is not a member yet.  So we start the enrollment process.
      //* Is there a monitor available?
      if (await isMonitorAvailable()) {
        //* Tell the coller to show the StartTrainingPage.
        return WhichPage.startTraining;
      } else {
        //* There isn't a monitor available, so tell the apop to show the WaitingListPage.
        return WhichPage.waitingList;
      }
    } else {
      // The app user is already a member.
      return WhichPage.impact;
    }
  }
}
