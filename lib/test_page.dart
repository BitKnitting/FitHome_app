import 'package:fithome_app/launch_to_impact/member_model.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import 'launch_to_impact/install_monitor/appts_model.dart';
import 'launch_to_impact/signin/auth_service.dart';

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  Logger log = Logger('test_page.dart');
  // Here we want to test getting the member's record from the database.

  @override
  Widget build(BuildContext context) {
    //_getApptDateTime(context);
    __createUserTest(context);

    return Container();
  }

  // Use an async function to get the appointment date time in the background.
  // I guess this should be a futurebuilder on the clock.
  void _getApptDateTime(BuildContext context) async {
    final appts = Provider.of<Appointments>(context);
    String appt = await appts.getAppt(context);
    // now that we have the string of the appt, get the hour, min, seconds.
    if (appt.isEmpty) {
      log.severe('The appointment date/time field is empty');
    }
    DateTime apptDateTime = DateTime.parse(appt);

    Duration duration = apptDateTime.difference(DateTime.now());

    print(
        '${(duration.inHours % 24).toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}');
    print('hello');
  }

  void __createUserTest(BuildContext context) async {
    final auth = Provider.of<AuthBase>(context);
    final member = Provider.of<Member>(context);
    await auth.createAccount(context, "goo@bar.com", "secret");
    member.getValues();
    String email = member.email;
    String password = member.password;
    print('email: $email and password: $password');
  }
}
