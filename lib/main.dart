import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:stack_trace/stack_trace.dart';
import 'launch_to_impact/landing_page.dart';
import 'launch_to_impact/signin/auth_service.dart';

// We are using the Provider package to pass around member info state
// between widgets below the MaterialApp Widget
import 'package:provider/provider.dart';

void main() {
  _initLogger();
  runApp(MyApp());
}

// *************************************************************************************
// Starts with login routing.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String title = 'FitHome';
    // We will provide the AuthBase login service.
    // The syntax for Provider requires the builder and child params.
    return Provider<AuthBase>(
      builder: (context) => Auth(),
      child: MaterialApp(
        title: title,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: LandingPage(),
      ),
    );
  }
}

// *************************************************************************************
// Code to set up logger.
void _initLogger() {
  Logger.root.level = Level.ALL; // i.e.: INFO.
  Logger.root.onRecord.listen((LogRecord rec) {
    final List<Frame> frames = Trace.current().frames;
    try {
      final Frame f = frames.skip(0).firstWhere((Frame f) =>
          f.library.toLowerCase().contains(rec.loggerName.toLowerCase()) &&
          f != frames.first);
      print(
          '${rec.level.name}: ${f.member} (${rec.loggerName}:${f.line}): ${rec.message}');
    } catch (e) {
      print(e.toString());
    }
  });
}
