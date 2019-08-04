import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';

enum InitState {
  start,
  wifi,
  noWifi,
  monitorAvailable,
  noMonitorAvailable,
  end
}

class LaunchState {
  LaunchState() {
    _controller.sink.add(InitState.start);
  }
  final _controller = StreamController<InitState>();
  Stream<InitState> get stream => _controller.stream;
  final Logger log = Logger('launch_state.dart');

  //* wifi availability check.
  Future<bool> isWifi({bool addToStream}) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        log.info('We can connect to wifi.');
        if (addToStream) {
          _controller.sink.add(InitState.wifi);
        }
        return true;
      }
    } on SocketException catch (_) {
      log.info('We cannot connect to wifi.');
      if (addToStream) {
        _controller.sink.add(InitState.noWifi);
      }
      return false;
    }
    if (addToStream) {
      _controller.sink.add(InitState.wifi);
    }
    return true;
  }

  Future<bool> isMonitorAvailable() async {
    log.info('monitor is not available');
    return false;
  }

  void setLaunchState({InitState state}) {
    _controller.sink.add(state);
  }

  void done() {
    _controller.close();
  }
}
