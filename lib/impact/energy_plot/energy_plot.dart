//
// A widget that builds a timeseries plot of energy readings.
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:async';
import 'energy_reading.dart';
import 'monitor_service.dart';

class EnergyPlot extends StatefulWidget {
  @override
  _EnergyPlotState createState() => _EnergyPlotState();
}

class _EnergyPlotState extends State<EnergyPlot> {
  List<EnergyReading> energyReadings = [];
  Widget energyLine;
  var series;
  StreamSubscription<EnergyReading> readingSubscription;
  final DummyMonitor monitor = DummyMonitor(sampleTime: 2);

  @override
  void dispose() {
    super.dispose();
    monitor.stop();
    readingSubscription.cancel();
  }

  @override
  void initState() {
    super.initState();

    // Listen to the stream of incoming meter readings.
    Stream<EnergyReading> readingStream = monitor.readings();
    readingSubscription = readingStream.listen(
      // Put the reading that comes into the stream into the plot data.
      (reading) => setState(
        () {
          // Add the reading to the List that gets plotted.
          energyReadings.add(reading);
          // Plot 10 readings.  This makes the line move...
          if (energyReadings.length > 10) {
            energyReadings.removeAt(0);
          }
        },
      ),
    );
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
    series = [
      charts.Series(
        id: 'Energy Readings',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        //  x-axis = time series
        domainFn: (EnergyReading reading, _) => reading.dateTime,
        // y-axis = watt measurement at the time.
        measureFn: (EnergyReading readings, _) => readings.watts,
        data: energyReadings,
      ),
    ];
    // Create a time series chart
    energyLine = charts.TimeSeriesChart(
      series,
      animate: true,
    );
  }
}
