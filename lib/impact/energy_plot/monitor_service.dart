//
// This class extends the MeterReading class to support emulating
// sensor data.  This is for development and testing.
//
import 'dart:async';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:fithome_app/database/DB_model.dart';
import 'package:logging/logging.dart';

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
    EnergyReading reading = EnergyReading(
        watts: rnd.nextDouble() * 1500.0, dateTime: DateTime.now());

    controller.add(reading);
  }
}

class FirebaseMonitor {
  static Future<StreamSubscription<Event>> getReadingsStream(
      String monitorName, void onData(var reading)) async {
    final DatabaseReference _readingsRef = DBRef.readingsRef(monitorName);
    final StreamSubscription<Event> readSubscription =
        _readingsRef.onChildAdded.listen((event) {
      var watts = event.snapshot.value["P"];
      DateTime datetime = DateTime.fromMillisecondsSinceEpoch(
          int.parse(event.snapshot.key) * 1000);
      print('watts: $watts  datetime: $datetime');
      if (watts == null) {
        onData(EnergyReading(dateTime: DateTime.now(), watts: 0));
      } else {
        onData(EnergyReading(dateTime: datetime, watts: watts));
      }
    });
    return readSubscription;
  }

  void stop() {}
}
