import 'dart:async';
import 'dart:math';

import 'energy_reading.dart';


class MockEnergyStream  {
  MockEnergyStream() {
    _addReading();
    Timer.periodic(Duration(seconds:5),(t){
      _addReading();
    });
  }
  final _controller = StreamController<EnergyReading>();
  //************************************************************************* */
  Stream<EnergyReading> get stream => _controller.stream;
   //************************************************************************* */ 
  void close() {
    _controller.close();
  }
  //************************************************************************* */
  void _addReading() {
    Random rnd = Random();
    EnergyReading reading = EnergyReading(
        watts: rnd.nextDouble() * 1500.0, dateTime: DateTime.now());
    _controller.add(reading);
  }
}
