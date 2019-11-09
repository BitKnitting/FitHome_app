//************************************************************************************** */
//
// This is the UI for the impact page.  The impact page is divided into two sections:
// - impact section:  This has an image (or image stream depending on the monitor state)
//   in the background.  Stacked on tope is a frosted card with info and action dependent
//   on the monitor is either not yet installed, learning about the homeowner's electricity
//   use, or actively in personal training.
//************************************************************************************** */

import 'dart:ui';

import 'package:fithome_app/common_code/form_submit_button.dart';
import 'package:fithome_app/common_code/globals.dart';
import 'package:fithome_app/common_code/image_feed_utils.dart';
import 'package:fithome_app/common_code/platform_alert_dialog.dart';
import 'package:fithome_app/database/DB_model.dart';
import 'package:fithome_app/impact/countdown_timer/countdown_timer.dart';
import 'package:fithome_app/impact/impact_stream.dart';
import 'package:fithome_app/launch_to_impact/install_monitor/appts_model.dart';
import 'package:fithome_app/launch_to_impact/install_monitor/monitors_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import 'energy_plot/energy_plot.dart';
import 'impact_content.dart';

class ImpactPage extends StatefulWidget {
  ImpactPage({@required this.monitorName, @required this.state});
  //*TODO: Sometimes just use as globals.  Sometimes pass into methods...
  final String state;
  final String monitorName;
  @override
  _ImpactPageState createState() => _ImpactPageState();
}

class _ImpactPageState extends State<ImpactPage> {
  Logger log = Logger('impact_page.dart');
  String title = 'Impact';

  @override
  Widget build(BuildContext context) {
    //*TODO: Get rest of asset pictures

    return Scaffold(
      //  Set the title based on the state of the monitor.
      appBar: AppBar(
        title: _setTitle(widget.state),
      ),
      body: Column(
        children: [
          Flexible(child: _buildImpactSection(), flex: 2),
          Flexible(child: _buildPlotArea(), flex: 1),
        ],
      ),
    );
  }

  //
  // What is shown is based on the status of the monitor.
  //
  Widget _buildImpactSection() {
    switch (widget.state) {
      case monitorNotActive:
        {
          return Stack(
            children: <Widget>[
              buildImageLayer('assets/misc/female-electrician.png'),
              _buildMonitorLayer(monitorStatus: monitorNotActive),
            ],
          );
        }

        break;
      case monitorLearning:
        {
          return Stack(
            children: <Widget>[
              buildImageLayer('assets/misc/histogram.gif'),
              _buildMonitorLayer(monitorStatus: monitorLearning),
            ],
          );
        }
        break;
      // When the monitor is active, the impact image changes.  When the impact image changes, the card showing the
      // impact the homewoner is making changes to reflect the equivalency.
      case monitorActive:
        {
          // There is a ranking stacked on top of the layers related to electricity use.
          return Stack(
            children: <Widget>[
              StreamBuilder(
                  // A path to one of the image assets has been put in the impactImages Stream
                  stream: ImpactImages().stream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData) {
                        // The data is the asset path. Build the Active content section of the page.
                        return Stack(
                          children: <Widget>[
                            buildImageLayer(snapshot.data),
                            _buildMonitorLayer(
                                monitorStatus: monitorActive,
                                impactImage: snapshot.data),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        log.severe('!!! ERROR: ${snapshot.error}');
                      }
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  }),
              // Inform the user on their baseline daily average electricity use
              // and their last 24 hours of electricity use.
              _buildDailyAvg(),
            ],
          );
        }
        break;
      //  If we get here, the member is in a state that isn't supported by ImpactPage. For example,
      //  If the status of the member shows start, they don't have a monitor installed yet.
      default:
        {
          log.severe(
              '!!! Error.  The expected status was either monitorActive, monitorLearning, monitorInstall.  (see globals.dart)');
          return _handleStatusError();
        }
        break;
    }
  }

  //************************************************************************** */
  //* Put a monitor card on top of the image.  Fill the contents of the card
  //* based on the status of the monitor.
  //************************************************************************** */

  _buildMonitorLayer({@required String monitorStatus, String impactImage}) {
    switch (monitorStatus) {
      case monitorNotActive:
        {
          return Positioned(
              bottom: 10,
              child: _monitorCard(status: monitorNotActive, height: 350.0));
        }
      case monitorLearning:
        {
          return Positioned(
              bottom: 10,
              child: _monitorCard(status: monitorLearning, height: 420.0));
        }
        break;
      case monitorActive:
        {
          return Positioned(
              bottom: 10,
              child: _monitorCard(
                  status: monitorActive,
                  height: 100.0,
                  impactImage: impactImage));
        }
        break;
    }
  }
  //************************************************************************** */
  //* The monitor card is frosted with content dependent on the monitor's status.
  //************************************************************************** */

  Widget _monitorCard(
      {@required String status, @required double height, String impactImage}) {
    double opacity = 0.5;
    return Padding(
      padding: EdgeInsets.only(left: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          // Frosted rectangle with curved corners.
          ClipRRect(
            borderRadius: BorderRadius.circular(24.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                height: height,
                width: MediaQuery.of(context).size.width - 20,
                color: Colors.white.withOpacity(opacity),
                // pass in the impact image to know which equivalent mapping is being made (e.g.: money, oil, trees saved...)
                child: _buildMonitorContent(
                    status: status, impactImage: impactImage),
                alignment: Alignment(0.0, 0.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildMonitorContent({@required String status, String impactImage}) {
    switch (status) {
      case monitorNotActive:
        {
          return _monitorInstallContent();
        }
        break;
      case monitorActive:
        {
          return _monitorActiveContent(impactImage);
        }
        break;
      case monitorLearning:
        {
          //return _monitorLearningContent();
          return Container();
        }
        break;
    }
  }

  //****************************************************************************** */
  /// Here we create a watch like countdown timer to let the member know how much
  /// Time is left before the electrician comes out.  The member may need to cancel
  /// the appointment.
  //****************************************************************************** */
  Widget _monitorInstallContent() {
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
                    text: 'Cancel Install', onPressed: _submit),
              )
            ],
          ),
        ),
      ],
    );
  }

  /// Get the member's appointment time so the watch face can show the right time.
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

  Widget _monitorLearningContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 300, 20, 0),
      child: SpinKitWave(
        color: Colors.black,
        size: 50.0,
      ),
    );
  }

  Widget _monitorActiveContent(String impactImage) {
    return _buildActiveContent(impactImage);
  }

  Widget _buildActiveContent(String impactImage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        electricitySaved(context, .5),
        Text(
          'Savings',
          style: Theme.of(context).textTheme.subhead,
        ),
        impactEquivalent(context, 4052, impactImage),
      ],
    );
  }
  //*TODO = Implement reschedule and cancel electrician install.

  _submit() {
    PlatformAlertDialog(
      title: 'Appointment',
      content: 'Rescheduling/cancelling not implemented yet.',
      defaultActionText: 'OK',
    ).show(context);
  }

  //************************************************************************** */
  //* Build the energy line plot based on incoming readings from the monitor.
  //************************************************************************** */
  _buildPlotArea() {
    switch (widget.state) {
      case monitorNotActive:
        {
          return _buildMonitorInstallWaitingPlot();
        }
        break;
      case monitorLearning:
      case monitorActive:
        {
          return EnergyPlot(monitorName: widget.monitorName);
        }
      //* If we get here, we're in an unexpected monitor status state (most
      //* likely a status of start)
      default:
        return Center(
          child: Container(
            color: Colors.grey.withOpacity(.6),
            child: new Text(
              "OOPs....",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            alignment: Alignment(0.0, 0.0),
          ),
        );
    }
  }

  //************************************************************************** */
  //* Build the daily average baseline electricity use
  //* The total amount of electricity saved by all FitHome participants (from the
  //* beginning of the program until right now).
  //************************************************************************** */
  _buildDailyAvg() {
    return (FutureBuilder(
        future: _getDailyAvg(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              Map baselineKWh = snapshot.data;
              return _drawBoxes(baselineKWh['daily_baseline'],baselineKWh['leakage_baseline']);
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        }));
  }

  Widget _drawBoxes(int dailyKWh, int leakageKWh) {
    return Positioned(
      top: 15,
      left: 10,
      child: Column(
        children: <Widget>[
          _avgDailyBox(true,dailyKWh),
          _avgDailyBox(false,leakageKWh),
        ],
      ),
    );
  }

  // ******************************************************************
  // The _avgDailyBox widget is here to draw too "boxes" of info on the
  // impact screen. 1) The baseline daily average electricity use in kWh.
  // 2) The amount of average electricity used in the past 24 hours =
  // also in kWh.
  // The baseline box is always filled with the grey color.
  // The last 24 hour box will be either:
  // green: the last 24 hours was less than the baseline.  YAY!
  // grey: the last 24 hours was about the same as the baseline.  OK...but
  // red: the last 24 hours was above the baseline.  BOO!
  //******************************************************************* */
  Widget _avgDailyBox(bool isBaseline,int avgKWh) {
    // Get the baseline value from the db.

    //   _monitorInfo = await DBHelper().getData(
    // dbRef: DBRef.memberMonitorRef(id),

    return Padding(
      padding: const EdgeInsets.fromLTRB(50, 0, 0, 10),
      // The container is the box.
      child: Container(
        alignment: Alignment(0, 0),
        height: 80,
        width: 300,
        decoration: BoxDecoration(
            color: Colors.grey[700],
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                offset: Offset(5, 5),
                blurRadius: 5,
              )
            ]),
        // The box contains two lines of text.
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: Column(
            children: <Widget>[
              Text(
                '21.0 kWh',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 30),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                child: Text(
                  isBaseline ? 'Baseline Daily Average' : 'Last 24 Hours',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[400],
                      fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //******************************************************************** */
  //* This method is called when the monitor status returned from the db
  //*TODO: The app shows a start status, but we're on impactPage code...
  //*TODO: Handle this error with getting action then ...
  Widget _handleStatusError() {
    return PlatformAlertDialog(
      title: 'Account Error',
      content: 'Shall we recreate your account?',
      defaultActionText: 'YES',
      cancelActionText: 'NO',
    );
  }

  //******************************************************************** */
  //* Set the page's title based on the monitor's state.
  //******************************************************************** */
  Widget _setTitle(String state) {
    String title = '';

    switch (state) {
      case monitorNotActive:
        {
          title = 'Monitor is not Active';
        }
        break;
      case monitorLearning:
        {
          title = 'Learning';
        }
        break;

      case monitorActive:
        {
          title = 'Active';
        }
        break;
      default:
        break;
    }
    return Text(title);
  }

  _getDailyAvg() async {
    return await DBHelper().getData(dbRef: DBRef.insightsRef(widget.monitorName));
  }
}

class _buildMonitorInstallWaitingPlot extends StatelessWidget {
  const _buildMonitorInstallWaitingPlot({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        //*TODO - This is most likely not a great layout.
        //EnergyPlot(),
        Center(
          child: Container(
            color: Colors.grey.withOpacity(.6),
            child: new Text(
              "Waiting for monitor installation...",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            alignment: Alignment(0.0, 0.0),
          ),
        ),
      ],
    );
  }
}
