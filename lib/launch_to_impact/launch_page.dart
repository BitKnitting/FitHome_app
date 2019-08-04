import 'package:fithome_app/common_code/platform_alert_dialog.dart';
import 'package:fithome_app/launch_to_impact/launch_state.dart';
import 'package:fithome_app/launch_to_impact/no_wifi_page.dart';
import 'package:fithome_app/launch_to_impact/waitlist_page.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class LaunchPage extends StatelessWidget {
  final Logger log = Logger('launch_page.dart');
  final LaunchState launchState = LaunchState();
  @override
  Widget build(BuildContext context) {
    log.info('showing launch page');
    return StreamBuilder(
        stream: launchState.stream,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return _progressIndicator();
            case ConnectionState.active:
              log.info('connection state is active: state = ${snapshot.data}');
              switch (snapshot.data) {
                case InitState.start:
                  launchState.isWifi(addToStream: true);
                  return _progressIndicator();
                case InitState.noWifi:
                  PlatformAlertDialog(
                    title: 'Where for out thou, wifi?',
                    content: 'Still can\'t connect to wifi.',
                    defaultActionText: 'OK',
                  ).show(context);
                  return _progressIndicator();

                case InitState.wifi:
                  launchState.isMonitorAvailable();
                  return _progressIndicator();
                case InitState.noMonitorAvailable:
                  launchState.done();
                  return WaitListPage();

                case InitState.monitorAvailable:
                  break;
              }

              break;

            case ConnectionState.done:
              break;
          }
        });
  }

  Widget _progressIndicator() {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
