import 'package:fithome_app/impact/impact_page.dart';
import 'package:fithome_app/launch_to_impact/install_monitor/install_monitor_page.dart';
import 'package:fithome_app/launch_to_impact/launch_check.dart';
import 'package:fithome_app/launch_to_impact/enroll_page.dart';
import 'package:fithome_app/launch_to_impact/waitlist_page.dart';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class LaunchPage extends StatelessWidget {
  final LaunchCheck launchCheck = LaunchCheck();
  final Logger log = Logger('launch_page.dart');
  @override
  Widget build(BuildContext context) {
    // return SafeArea(
    //     child: Scaffold(
    //         appBar: AppBar(
    //           title: Text(AppTitleWrapper.title),
    //           elevation: 5.0,
    //         ),
    return Container(
        //resizeToAvoidBottomInset: true,
        child: FutureBuilder(
            future: launchCheck.checkMembership(context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                log.info(
                    'checking for membership is done.  state: ${snapshot.data}');
                switch (snapshot.data) {
                  case UserState.enroll:
                    return EnrollPage();
                  case UserState.memberNoInstallDate:
                    return InstallMonitorPage();
                  case UserState.member:
                    return ImpactPage();
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
            }));
  }
}
