
import 'package:fithome_app/launch_to_impact/launch_check.dart';
import 'package:fithome_app/launch_to_impact/start_training_page.dart';
import 'package:fithome_app/launch_to_impact/waitlist_page.dart';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class LaunchPage extends StatelessWidget {
  final LaunchCheck launchCheck = LaunchCheck();
  final Logger log = Logger('launch_page.dart');
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: Text('FitHome'),
              elevation: 5.0,
            ),
            //resizeToAvoidBottomInset: true,
            body: FutureBuilder(
                future: launchCheck.checkForMembership(context),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    log.info(
                        'checking for membership is done.  state: ${snapshot.data}');
                    switch (snapshot.data) {
                      case UserState.start_training:
                        return StartTrainingPage();
                      case UserState.member:
                        return Text('member');
                      case UserState.waitlist:
                        return WaitListPage();
                    }
                  } else {
                    return Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return Text('Please contact fithome member services.');
                })));
  }
}
