import 'package:fithome_app/launch_to_impact/launch_check.dart';

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
              elevation: 2.0,
            ),
            body: FutureBuilder(
                future: launchCheck.checkForMembership(context),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    switch (snapshot.data) {
                      case UserState.start_training:
                        return Text('start_training');
                      case UserState.member:
                        return Text('member');
                      case UserState.waitlist:
                        return Text('waitlist');
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
