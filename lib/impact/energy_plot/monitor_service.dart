//
// This class extends the MeterReading class to support emulating
// sensor data.  This is for development and testing.
//
import 'dart:async';
import 'dart:math';

import 'energy_reading.dart';

abstract class MonitorBase {
  Stream<EnergyReading> readings();
  void stop();
}

class DummyMonitor implements MonitorBase {
  Timer _timer;
  final int sampleTime;
  DummyMonitor({this.sampleTime = 2});

  StreamController<EnergyReading> controller;

  Stream<EnergyReading> readings() {
    controller = StreamController<EnergyReading>(
        onListen: start, onPause: stop, onResume: start, onCancel: stop);

    return controller.stream;
  }

  void start() {
    _timer = Timer.periodic(Duration(seconds: this.sampleTime), _timerCallBack);
  }

  void stop() {
    _timer.cancel();
  }

  void _timerCallBack(Timer timer) {
    _putEnergyReadingIntoStream();
  }

  void _putEnergyReadingIntoStream() {
    Random rnd = Random();
    EnergyReading reading = EnergyReading(rnd.nextInt(1500), DateTime.now());

    controller.add(reading);
  }
}
