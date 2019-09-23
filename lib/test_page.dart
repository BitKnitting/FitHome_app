import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:fithome_app/launch_to_impact/member_model.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';


import 'database/DB_model.dart';
import 'impact/energy_plot/energy_reading.dart';
import 'launch_to_impact/install_monitor/appts_model.dart';
import 'launch_to_impact/signin/auth_service.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  List<EnergyReading> energyReadings = [];
  Logger log = Logger('test_page.dart');
  // Here we want to test getting the member's record from the database.

  @override
  Widget build(BuildContext context) {
    //_getApptDateTime(context);
    //__createUserTest(context);
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: Text('TEST'),
              elevation: 5.0,
            ),
            //resizeToAvoidBottomInset: true,
            body: _plotReadingsTest(context)));
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

  /************************************************* */
  // Learning how to get real time data from Firebase store.

  bool _ignoreReading(EnergyReading energyReading) {
    const _secondsDiff = 15;
    //*TODO: Get datetime from Firebase.
    Duration difference = DateTime.now().difference(energyReading.dateTime);
    if (difference.inSeconds > _secondsDiff) {
      return true;
    }
    return false;
  }

  Widget _plotReadingsTest(BuildContext context) {
    final DatabaseReference _readingsRef = DBRef.readingsRef('bambi-09152019');
    final Query dBquery = _readingsRef.limitToLast(1);
    return StreamBuilder(
        stream: dBquery.onChildAdded,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            EnergyReading energyReading =
                EnergyReading.fromSnapshot(snapshot.data.snapshot);
            // The first reading is the last reading in the db.  We ignore this one.
            if (_ignoreReading(energyReading)) {
              return Center(child: CircularProgressIndicator());
            }
            return Column(
              children: [
                Flexible(child: Container(), flex: 3),
                Flexible(child: _energyPlot(energyReading), flex: 1),
              ],
            );
          }

          // No data
          return Center(child: CircularProgressIndicator());
        });
  }

  Widget _energyPlot(EnergyReading reading) {
    energyReadings.add(reading);
    // Plot 10 readings.  This makes the line move...
    if (energyReadings.length > 10) {
      energyReadings.removeAt(0);
    }

    List<charts.Series<EnergyReading, DateTime>> _seriesEnergyReadings = [
      charts.Series<EnergyReading, DateTime>(
        id: 'Energy Readings',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        //  x-axis = time series
        domainFn: (EnergyReading reading, _) => reading.dateTime,
        // y-axis = watt measurement at the time.
        measureFn: (EnergyReading reading, _) => reading.watts,
        data: energyReadings,
      ),
    ];
    // Create a time series chart
    var chart = charts.TimeSeriesChart(
      _seriesEnergyReadings,
      animate: true,
      // domainAxis: charts.DateTimeAxisSpec(
      //   tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(
      //     day: charts.TimeFormatterSpec(
      //       format: 'm:s',
      //       transitionFormat: 'm',
      //     ),
      //   ),
      // )
    );
    return (Padding(
      padding: EdgeInsets.all(8.0),
      child: SizedBox(
        height: 200,
        child: chart,
      ),
    ));
  }
}

