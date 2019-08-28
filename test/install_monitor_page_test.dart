// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:fithome_app/launch_to_impact/install_monitor/appts_%20model.dart';
import 'package:fithome_app/launch_to_impact/install_monitor/install_monitor_page.dart';
import 'package:fithome_app/launch_to_impact/signin/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
//     testWidgets('install monitor page smoke test', (WidgetTester tester) async {});
// }
  testWidgets(
    'install monitor page smoke test',
    (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AuthBase>(
              builder: (context) => Auth(),
            ),
            Provider<Appointments>(
              builder: (context) => Appointments(),
            ),
          ],
          child: Builder(
            builder: (_) => MaterialApp(
              home: InstallMonitorPage(),
            ),
          ),
        ),
      );
    },
  );
}
