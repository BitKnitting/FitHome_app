//
// A widget that builds a timeseries plot of energy readings.
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:async';
import 'energy_reading.dart';
import 'monitor_service.dart';

class EnergyPlot extends StatefulWidget {
  final String monitorName;
  EnergyPlot({@required this.monitorName});
  @override
  _EnergyPlotState createState() => _EnergyPlotState();
}

class _EnergyPlotState extends State<EnergyPlot> {
  List<EnergyReading> energyReadings = [];
  Widget energyLine;
  var series;
  final DummyMonitor monitor = DummyMonitor(sampleTime: 2);
  StreamSubscription _subscriptionName;
  @override
  void dispose() {
    if (_subscriptionName != null) {
      _subscriptionName.cancel();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    FirebaseMonitor.getReadingsStream(widget.monitorName,_onNewReading)
        .then((StreamSubscription s) => _subscriptionName = s);

    // Listen to the stream of incoming meter readings.
    // Stream<EnergyReading> readingStream = monitor.readings();
    // readingSubscription = readingStream.listen(
    //   // Put the reading that comes into the stream into the plot data.
    //   (reading) => setState(
    //     () {
    //       // Add the reading to the List that gets plotted.
    //       energyReadings.add(reading);
    //       // Plot 10 readings.  This makes the line move...
    //       if (energyReadings.length > 10) {
    //         energyReadings.removeAt(0);
    //       }
    //     },
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    _buildXY();
    return energyLine;
  }

  //
  // Create a time series chart using energy readings.
  // Encapsulates setting up the series and energyLine
  // variables.
  //
  void _buildXY() {
    // Set the x/y info of the time series.
    // Check to see if there are any energy readings.
    //*TODO: More detailed handling.  Here I just don't want to get null returned.
    if (energyReadings.isEmpty) {
      for (int i = 0; i < 9; i++) {
        energyReadings.add(EnergyReading(dateTime: DateTime.now(), watts: 0));
      }
    }
    series = [
      charts.Series(
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
    energyLine = charts.TimeSeriesChart(
      series,
      animate: true,
    );
  }

  void _onNewReading(reading) {
    setState(
      () {
        // Add the reading to the List that gets plotted.
        energyReadings.add(reading);
        // Plot 10 readings.  This makes the line move...
        if (energyReadings.length > 10) {
          energyReadings.removeAt(0);
        }
      },
    );
  }
}
