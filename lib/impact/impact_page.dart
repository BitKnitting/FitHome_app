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
import 'package:fithome_app/impact/countdown_timer/countdown_timer.dart';
import 'package:fithome_app/impact/impact_stream.dart';
import 'package:fithome_app/launch_to_impact/install_monitor/monitors_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

import 'energy_plot/energy_plot.dart';
import 'impact_content.dart';

enum MemberState { unknown, waiting, baseline, active }

class ImpactPage extends StatefulWidget {
  @override
  _ImpactPageState createState() => _ImpactPageState();
}

class _ImpactPageState extends State<ImpactPage> {
  Logger log = Logger('impact_page.dart');
  //*TODO: TBD - do i need memberState???
  MemberState memberState = MemberState.unknown;

  @override
  Widget build(BuildContext context) {
    //*TODO: Get rest of asset pictures
    //*TODO: Build background of plot
    //*TODO: Future builder to say what state we're in?  Let's go with this for now.

    return Column(
      children: [
        AppBar(title: Text("Impact")),
        Expanded(child: _buildImpactSection(), flex: 3),
        Expanded(child: _buildPlotArea(), flex: 1),
      ],
    );
  }

  //
  // The impact images will be updated by the impactImpageSteam
  //
  _buildImpactSection() {
    final monitors = Provider.of<Monitors>(context);
    return FutureBuilder(
        future: monitors.getStatus(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              switch (snapshot.data) {
                case monitorInstall:
                  {
                    return Stack(
                      children: <Widget>[
                        _buildImageLayer('assets/misc/female-electrician.png'),
                        _buildMonitorLayer(monitorStatus: monitorInstall),
                      ],
                    );
                  }

                  break;
                case monitorLearning:
                  {
                    return Stack(
                      children: <Widget>[
                        _buildImageLayer('assets/misc/histogram.gif'),
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
                              if (snapshot.connectionState ==
                                  ConnectionState.active) {
                                if (snapshot.hasData) {
                                  // The data is the asset path. Build the Active content section of the page.
                                  return Stack(
                                    children: <Widget>[
                                      _buildImageLayer(snapshot.data),
                                      _buildMonitorLayer(
                                          monitorStatus: monitorActive,
                                          impactImage: snapshot.data),
                                    ],
                                  );
                                } else if (snapshot.hasError) {
                                  log.severe('!!! ERROR: ${snapshot.error}');
                                }
                              } else {
                                return Center(
                                    child: CircularProgressIndicator());
                              }
                            }),
                        _buildRanking(),
                        _buildTotalElectricitySaved(),
                      ],
                    );
                  }
                  break;
              }
            } else {
              return Text('');
            }
          } else {
            return Text('');
          }
        });
  }

  _buildImageLayer(String impactImageName) {
    AssetImage assetImage = AssetImage(impactImageName);
    return Row(
      children: <Widget>[
        Expanded(
          child: FadeInImage(
            placeholder: MemoryImage(kTransparentImage),
            image: assetImage,
            fit: BoxFit.fill,
          ),
        ),
      ],
    );
  }

  //************************************************************************** */
  //* Put a monitor card on top of the image.  Fill the contents of the card
  //* based on the status of the monitor.
  //************************************************************************** */

  _buildMonitorLayer({@required String monitorStatus, String impactImage}) {
    switch (monitorStatus) {
      case monitorInstall:
        {
          return Positioned(
              bottom: 10,
              child: _monitorCard(status: monitorInstall, height: 420.0));
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
      case monitorInstall:
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
          return _monitorLearningContent();
        }
        break;
    }
  }

  Widget _monitorInstallContent() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 30, 20, 0),
          child: CountdownTimer(
              title: 'Installation in', day: 2, hour: 0, min: 20),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 50),
              child: FormSubmitButton(text: 'Reschedule', onPressed: _submit),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 50),
              child:
                  FormSubmitButton(text: 'Cancel Install', onPressed: _submit),
            )
          ],
        ),
      ],
    );
  }

  Widget _monitorLearningContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 30, 20, 0),
      child: CountdownTimer(
          title: 'Learning completed in', day: 1, hour: 10, min: 20),
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
    // if (impactImage.contains(impactMoney)) {
    //   return Text(impactMoney);
    // } else if (impactImage.contains(impactTrees)) {
    //   return Text(impactTrees);
    // } else if (impactImage.contains(impactOil)) {
    //   return Text(impactOil);
    // } else {
    //   log.info(
    //       'Received an impact image that does not contain a substring representing what impact area it represents.  The name of the impact image is $impactImage');
    //   return Text(impactImage);
    // }
  }

  _submit() {}

  _buildPlotArea() {
    final monitors = Provider.of<Monitors>(context);
    return FutureBuilder(
        future: monitors.getStatus(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              switch (snapshot.data) {
                case monitorInstall:
                  {
                    return new _buildMonitorInstallWaitingPlot();
                  }
                  break;
                case monitorLearning:
                case monitorActive:
                  {
                    return EnergyPlot();
                  }
              }
            }
          } else {
            return Container();
          }
        });
  }

  //************************************************************************** */
  //* The homeowner's ranking relative to other FitHome trainees is placed on
  //* The upper right hand corner of the image.
  //************************************************************************** */
  Widget _buildRanking() {
    return Positioned(
      top: 10,
      right: 10,
      child: Stack(
        children: [
          Container(
            alignment: Alignment(0, 0),
            height: 90,
            width: 90,
            decoration: BoxDecoration(
                color: Colors.green[700],
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(5, 5),
                    blurRadius: 5,
                  )
                ]),
            child: Text(
              '33',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 40),
            ),
          ),
        ],
      ),
    );
  }

  //************************************************************************** */
  //* The total amount of electricity saved by all FitHome participants (from the
  //* beginning of the program until right now).
  //************************************************************************** */
  _buildTotalElectricitySaved() {
    return Positioned(
      top: 15,
      left: 10,
      child: Stack(
        children: [
          Container(
            alignment: Alignment(0, 0),
            height: 80,
            width: 300,
            decoration: BoxDecoration(
                color: Colors.green[700],
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(5, 5),
                    blurRadius: 5,
                  )
                ]),
            child: Text(
              '12.9 kWh',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 40),
            ),
          ),
        ],
      ),
    );
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
        EnergyPlot(),
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
