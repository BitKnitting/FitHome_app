import 'dart:async';
import 'dart:math';

import 'package:fithome_app/impact/energy_plot/energy_stream.dart';

import 'energy_reading.dart';
import 'package:logging/logging.dart';

class MockEnergyStream extends EnergyStream {
  final Logger log = Logger('mock_energy_stream.dart');
  Timer timer;
  StreamController<EnergyReading> controller =
      StreamController<EnergyReading>();
  //************************************************************************* */
  Future startReadingsStream(
      // Data is randomly generated...
      // The monitorName is not used.
      String monitorName,
      void onData(var reading)) async {
    timer = Timer.periodic(Duration(seconds: 5), _timerCallBack);
    _addReading();
    controller.stream.listen((reading) {
      onData(reading);
    }, onDone: () {
      log.info("Done listening for energy readings.");
    }, onError: (error) {
      log.info("!!! Error: $error");
    });
  }

  void closeReadingsStream() {
    controller.close();
  }

  //************************************************************************* */
  void _timerCallBack(Timer timer) {
    _addReading();
  }

  void _addReading() {
    Random rnd = Random();
    EnergyReading reading = EnergyReading(
        watts: rnd.nextDouble() * 1500.0, dateTime: DateTime.now());
    controller.add(reading);
  }
}
