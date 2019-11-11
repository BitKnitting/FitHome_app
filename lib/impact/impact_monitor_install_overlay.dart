import 'package:fithome_app/common_code/form_submit_button.dart';
import 'package:fithome_app/common_code/platform_alert_dialog.dart';
import 'package:fithome_app/launch_to_impact/install_monitor/appts_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
//****************************************************************************** */
/// We let the user know when their appointment is scheduled for an electrician
/// to come out and install the monitor.  The homeowner can cancel the appointment
/// if they need to.
//****************************************************************************** */

class ImpactMonitorInstallOverlay extends StatelessWidget {
  final Logger log = Logger('impact_monitor_install_overlay.dart');
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Flexible(
          child: FutureBuilder(
              future: _getApptDateTime(context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    DateTime apptDateTime = snapshot.data;
                    Duration difference =
                        apptDateTime.difference(DateTime.now());
                    String dayStr = difference.inDays > 1 ? "days" : "day";
                    dayStr = '${difference.inDays}' + ' ' + '$dayStr';
                    String hourStr =
                        difference.inHours % 24 > 1 ? "hours" : "hour";
                    hourStr = '${difference.inHours % 24}' + ' ' + '$hourStr';
                    String minStr =
                        difference.inMinutes % 24 > 1 ? "minutes" : "minute";
                    minStr = '${difference.inMinutes % 60}' + ' ' + '$minStr';

                    return Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20.0, 30, 20, 0),
                          child: Text(
                            'Appointment scheduled for',
                            style: Theme.of(context).textTheme.subhead,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20.0, 30, 20, 0),
                          child: Text(
                            '${DateFormat.yMMMMd().format(apptDateTime)}',
                            style: Theme.of(context).textTheme.display1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20.0, 30, 20, 0),
                          child: Text(
                            'Installation in $dayStr, $hourStr, $minStr',
                            style: Theme.of(context).textTheme.subhead,
                          ),
                        ),
                      ],
                    );
                  }
                } else {
                  return Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
              }),
          flex: 4,
        ),
        Flexible(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              //*TODO: handle appointment cancellation.
              Padding(
                padding: const EdgeInsets.only(top: 30, bottom: 20),
                child: FormSubmitButton(
                    text: 'Cancel Install', onPressed: _cancelAppt(context)),
              )
            ],
          ),
        ),
      ],
    );
  }
  //****************************************************************************** */
  /// Get the member's appointment time.
  //****************************************************************************** */
  Future<DateTime> _getApptDateTime(BuildContext context) async {
    final appts = Provider.of<Appointments>(context);
    String appt = await appts.getAppt(context);
    // now that we have the string of the appt, get the hour, min, seconds.
    if (appt == null) {
      log.severe('The appointment date/time field is empty');
      return null;
    }
    return (DateTime.parse(appt));
  }
  //*TODO = Implement reschedule and cancel electrician install.
  //****************************************************************************** */
  /// Cancel the scheduled appointment.
  //****************************************************************************** */
  _cancelAppt(BuildContext context) {
    PlatformAlertDialog(
      title: 'Appointment',
      content: 'Rescheduling/cancelling not implemented yet.',
      defaultActionText: 'OK',
    ).show(context);
  }

}
