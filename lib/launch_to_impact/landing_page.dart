import 'package:fithome_app/impact/impact_page.dart';
import 'package:fithome_app/launch_to_impact/start_training_page.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'code_route_check.dart';
import 'no_wifi_page.dart';
import 'waitlist_page.dart';

class LandingPage extends StatelessWidget {
  final Logger log = Logger('landing_page.dart');
  final RouteCheck routeCheck = RouteCheck();

  @override
  Widget build(BuildContext context) {
    log.info('building FutureBuilder');
    return FutureBuilder(
        future: routeCheck.checkWhichPageToBuild(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              log.info('Sign in failed, Error: ${snapshot.error}');
              return Container(child: Text('${snapshot.error}'));
            } else {
              log.info('snapshot data: ${snapshot.data}');
              switch (snapshot.data) {
                case WhichPage.noWiFi:
                  {
                    log.info(
                        'Can screen be popped: ${Navigator.canPop(context)}');
                    return NoWifiPage();
                  }
                  break;
                case WhichPage.startTraining:
                  {
                    return StartTrainingPage();
                  }
                  break;
                case WhichPage.waitingList:
                  {
                    log.info(
                        'Can screen be popped: ${Navigator.canPop(context)}');
                    return WaitingListPage();
                  }
                  break;
                case WhichPage.impact:
                  {
                    return ImpactPage();
                  }
                  break;
              }
            }
            //* We're nto ready yet so show a progress indicator.
          } else {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          // Shouldn't get here.  Added to remove the warning there was no return.
          return Container();
        });
  }
}
