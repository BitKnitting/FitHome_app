import 'dart:async';

import 'dart:math';
const secsBetweenUpdate = 5;
const List<String> impactImagesList = [
      'assets/impactImages/414x736/money_1.jpeg',
      'assets/impactImages/414x736/money_2.jpeg',
      'assets/impactImages/414x736/money_3.jpeg',
      'assets/impactImages/414x736/money_4.jpeg',
      'assets/impactImages/414x736/money_5.jpeg',
      'assets/impactImages/414x736/money_6.jpeg',
      'assets/impactImages/414x736/money_7.jpeg',
      'assets/impactImages/414x736/money_8.jpeg',
      'assets/impactImages/414x736/money_9.jpeg',
      'assets/impactImages/414x736/money_10.jpeg',
      'assets/impactImages/414x736/oil_1.jpeg',
      'assets/impactImages/414x736/oil_2.jpeg',
      'assets/impactImages/414x736/oil_3.jpeg',
      'assets/impactImages/414x736/oil_4.jpeg',
      'assets/impactImages/414x736/oil_5.jpeg',
    ];
class ImpactImages {
   ImpactImages() {
    _controller.sink.add(_getRandomImpactImage());
    Timer.periodic(Duration(seconds: secsBetweenUpdate), (t) {
      _controller.sink.add(_getRandomImpactImage());
    });}  
  final _controller = StreamController<String>();
  //************************************************************************* */
  Stream<String> get stream => _controller.stream;
  //************************************************************************* */
  void close() {
    _controller.close();
  }
  //************************************************************************* */
  /// Return one of the impact images to be placed into the stream.
  //************************************************************************* */

  String _getRandomImpactImage() {
    Random rnd = Random();
    return impactImagesList[rnd.nextInt(impactImagesList.length)];
  }
}
