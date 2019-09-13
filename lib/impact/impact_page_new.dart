import 'dart:ui';

import 'package:fithome_app/impact/impact_stream.dart';
import 'package:fithome_app/launch_to_impact/install_monitor/monitors_model.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import 'energy_plot/energy_plot.dart';

enum MemberState { unknown, waiting, baseline, active }

class ImpactPage extends StatefulWidget {
  @override
  _ImpactPageState createState() => _ImpactPageState();
}

class _ImpactPageState extends State<ImpactPage> {
  Logger log = Logger('impact_page.dart');
  MemberState memberState = MemberState.unknown;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //*TODO: Get rest of asset pictures
    //*TODO: Build background of plot
    //*TODO: Stack to overlay what state we're in...
    final monitors = Provider.of<Monitors>(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Your Impact'),
        ),
        body: Column(
          children: [
            Expanded(child: _buildImpactImage(), flex: 3),
            Expanded(child: EnergyPlot(), flex: 1),
          ],
        ),
      ),
    );
  }

  //
  // The impact images will be updated by the impactImpageSteam
  //
  _buildImpactImage() async {
    return StreamBuilder(
        stream: ImpactImages().stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              return _impactImage(snapshot.data);
            } else if (snapshot.hasError) {
              log.severe('!!! ERROR: ${snapshot.error}');
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  // The image invokes a positive emotion about saving electricity and
  // be a reminder of an aspect of the environment - trees, oil, money.
  // The images come from unsplash categories for trees, oil, money.
  Widget _impactImage(String impactImageName) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Image.asset(
            impactImageName,
            fit: BoxFit.fill,
          ),
        ),
      ],
    );
  }

  Widget _overlayContent(String status) {
    // First put down a frosted layer.
    return _frostedCard(Text('hello'), MediaQuery.of(context).size.height / 7,
        35 + MediaQuery.of(context).size.height / 7, .6);
  }

  Widget _frostedCard(
      Widget child, double height, double bottom, double opacity) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, bottom),
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
                width: MediaQuery.of(context).size.width,
                color: Colors.white.withOpacity(opacity),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
