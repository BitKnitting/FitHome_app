import 'package:fithome_app/common_code/platform_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'code_route_check.dart';
import 'landing_page.dart';

class NoWifiPage extends StatelessWidget {
  final Logger log = Logger('no_wifi_page.dart');
  @override
  Widget build(BuildContext context) {
    log.info('showing NoWifiPage');
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('WiFi Not Available'),
          elevation: 2.0,
        ),
        body: Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Cannot connect to the internet.\n Please check your wifi connection.\n\n When wifi is available, ',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: RaisedButton(
                    child: Text("Try Again"),
                    onPressed: () => _tryAgain(context),
                    color: Colors.blue,
                    textColor: Colors.white,
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    splashColor: Colors.grey,
                    elevation: 8.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _tryAgain(BuildContext context) async {
    bool isConnected = await RouteCheck().isWifi();
    if (isConnected) {
      log.info('The Try again button was pushed.  We connected. ');
      // Pop off the no wifi page
      log.info(Navigator.canPop(context));
      Navigator.maybePop(context);
      // Push on the Landing page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LandingPage()),
      );
    } else {
      log.info('The Try again button was pushed. Still not connected.');
      PlatformAlertDialog(
        title: 'Where for out thou, wifi?',
        content: 'Still can\'t connect to wifi.',
        defaultActionText: 'OK',
      ).show(context);
    }
  }
}
