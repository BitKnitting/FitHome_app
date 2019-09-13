import 'dart:async';

import 'dart:math';

class ImpactImages {
  final _controller = StreamController<String>();
  Stream<String> get stream => _controller.stream;
  final int imageUpdateDuration = 5;
  Timer timer;
  List<String> _impactImageList = [];
  ImpactImages() {
    _impactImageList = _getListOfImages();
    timer = Timer.periodic(Duration(seconds: imageUpdateDuration), _update);
    _update(timer);
  }
  //************************************************************ */
  // Stream gets updated every imageUpdateDuration seconds.
  //************************************************************ */
  void _update(Timer timer) {
    _controller.sink.add(_getRandomImpactImage());
  }

  void displose() {
    _controller.close();
  }

  //************************************************************ */
  // Grab a random impact image from our list.
  //************************************************************ */
  String _getRandomImpactImage() {
    Random rnd = Random();
    return _impactImageList[rnd.nextInt(_impactImageList.length)];
  }

  //************************************************************ */
  // Impact image assets.
  //************************************************************ */

  List<String> _getListOfImages() {
    const List<String> _impactImages = [
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

    return _impactImages;
  }
}
