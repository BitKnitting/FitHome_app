import 'package:fithome_app/common_code/form_submit_button.dart';
import 'package:fithome_app/impact/impact_page.dart';
import 'package:fithome_app/impact/impact_stream.dart';
import 'package:fithome_app/impact/impact_utils.dart';
import 'package:flutter/material.dart';

const ContentOverlayHeight = 140.0;

class LeaksImpactPage extends ImpactPage {
  LeaksImpactPage({@required this.monitorName});
  final String monitorName;

  final double percentTotalLeakage = 0.0;

  Widget buildContentSection(BuildContext context) {
    return FutureBuilder(
        future: getImpactValues(monitorName),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              percentTotalLeakage = _calcPercentTotalLeakage(snapshot.data);
              return Container(
                  height: 2000, child: _impactSection(context, snapshot.data));
            } else {
              return Center(child: CircularProgressIndicator());
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  Widget buildActionSection(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.grey[300],
        child: FormSubmitButton(text: 'FIX LEAKS', onPressed: _fixLeaks),
        alignment: Alignment(0.0, 0.0),
      ),
    );
  }

  Widget setTitle(BuildContext context) {
    return (Text('Electricity Leaks'));
  }

  //************************************************************************************** */
  Widget _impactSection(BuildContext context, Map insights) {
    return StreamBuilder(
        // A path to one of the image assets has been put in the impactImages Stream
        stream: ImpactImages().stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              return Stack(children: <Widget>[
                ImpactImage(image: snapshot.data),
                _buildContentOverlay(context, snapshot.data, insights),
              ]);
            } else {
              return Center(child: CircularProgressIndicator());
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  //************************************************************************************** */
  Widget _buildContentOverlay(
      BuildContext context, String image, Map insights) {
    return Positioned(
      bottom: 0,
      child: Container(
          height: ContentOverlayHeight,
          width: MediaQuery.of(context).size.width,
          color: Colors.white70,
          // margin: EdgeInsets.symmetric(horizontal: 10.0),

          child: Column(
            children: <Widget>[
              _showPercentTotalLeakage(context),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _showDrippingFawcet(context),
                  // _electricitySaved(context, insights),
                  // _dailyAverage(context, insights),
                  // _impactEquivalent(context, image, insights),
                ],
              ),
            ],
          )),
    );
  }

  _fixLeaks() {}

  Widget _showPercentTotalLeakage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: Align(
        alignment: Alignment.topCenter,
        child: Text(
          percentTotalLeakage.toString() + "% of Total Electricity",
          style: Theme.of(context).textTheme.subhead,
        ),
      ),
    );
  }

  //*TODO handle errors.
  double _calcPercentTotalLeakage(Map insights) {
    double leakageBaselineKWh = insights['leakage_baseline'] / 1000.0 * 24;

    return leakageBaselineKWh / insights['daily_baseline'] * 100;
  }
}
