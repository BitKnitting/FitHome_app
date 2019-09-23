import 'package:fithome_app/common_code/platform_alert_dialog.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

class PlatformExceptionAlertDialog extends PlatformAlertDialog {
  PlatformExceptionAlertDialog({
    @required String title,
    @required PlatformException exception,
  }) : super(title: title, content: exception.message, defaultActionText: 'OK');
}
