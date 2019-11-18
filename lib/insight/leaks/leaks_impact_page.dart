import 'package:fithome_app/common_code/form_submit_button.dart';
import 'package:fithome_app/common_code/globals.dart';
import 'package:fithome_app/impact/impact_page.dart';
import 'package:fithome_app/impact/impact_stream.dart';
import 'package:fithome_app/impact/impact_utils.dart';
import 'package:flutter/material.dart';

const ContentOverlayHeight = 150.0;

class LeaksImpactPage extends ImpactPage {
  LeaksImpactPage({@required this.monitorName});
  final String monitorName;

  Widget buildContentSection(BuildContext context) {
    return FutureBuilder(
        future: getImpactValues(monitorName),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
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
    ImpactEquivalent impactEquivalent =
        ImpactEquivalent(impactType: ImpactType.leakage);
    return StreamBuilder(
        stream: ImpactImages().stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              impactEquivalent.getImpactEquivalent(snapshot.data, insights);
              return Stack(children: <Widget>[
                ImpactImage(image: snapshot.data),
                _buildContentOverlay(context, impactEquivalent),
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
      BuildContext context, ImpactEquivalent impactEquivalent) {
    return Positioned(
      bottom: 0,
      child: Container(
        height: ContentOverlayHeight,
        width: MediaQuery.of(context).size.width,
        color: Colors.white70,
        // margin: EdgeInsets.symmetric(horizontal: 10.0),

        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
              child: _showPercentTotalLeakage(context, impactEquivalent),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _showDrippingFawcet(
                      context, impactEquivalent.leakageBaseline),
                  _showYearlyLeakage(context, impactEquivalent.leakageBaseline),
                  _showImpactEquivalent(context, impactEquivalent),
                  //     // _electricitySaved(context, insights),
                  //     // _dailyAverage(context, insights),
                  //     // _impactEquivalent(context, image, insights),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _fixLeaks() {}

  Widget _showPercentTotalLeakage(
      BuildContext context, ImpactEquivalent impactEquivalent) {
    double percentTotalLeakage = _calcPercentTotalLeakage(
        impactEquivalent.leakageBaseline, impactEquivalent.dailyBaseline);
    return Padding(
      padding: const EdgeInsets.only(bottom: 7.0),
      child: Align(
        alignment: Alignment.topCenter,
        child: Text(
          percentTotalLeakage.toString() + "% of Total Electricity",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.red,
            shadows: [
              Shadow(
                blurRadius: 3.0,
                color: Colors.black,
                offset: Offset(2.0, 3.0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //*TODO handle errors.
  double _calcPercentTotalLeakage(
      double leakageBaseline, double dailyBaseline) {
    double leakageBaselineKWh = leakageBaseline / 1000.0 * 24;

    return leakageBaselineKWh / dailyBaseline * 100;
  }

  Widget _showDrippingFawcet(BuildContext context, double leakage) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        width: ContentOverlayHeight - 30,
        height: ContentOverlayHeight,
        // margin: EdgeInsets.only(top: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Align(
              alignment: Alignment.topRight,
              child: Container(
                  width: 80,
                  height: 85,
                  margin: EdgeInsets.fromLTRB(0, 15, 20, 0),
                  // margin: EdgeInsets.only(right: 17),
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                          left: 0,
                          right: 0,
                          child: Image.asset(
                              'assets/insightsImages/drippingFaucet.png')),
                      Positioned(
                          right: 0,
                          bottom: 0,
                          child: Text(
                            leakage.toString() + ' W',
                            style: Theme.of(context).textTheme.subhead,
                          )),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _showYearlyLeakage(BuildContext context, double leakage) {
    double leakageKWh = leakage / 1000 * 24 * 365;
    return Center(
      // width: ContentOverlayHeight - 30,
      // height: ContentOverlayHeight,
      child: Text(
        leakageKWh.toStringAsFixed(2) + " kWh/year",
        style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _showImpactEquivalent(
      BuildContext context, ImpactEquivalent impactEquivalent) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        width: ContentOverlayHeight - 30,
        height: ContentOverlayHeight,
        child: Column(
          children: <Widget>[
            Text(
              'Yearly Impact',
              style: Theme.of(context).textTheme.subhead,
            ),
            Image.asset(impactEquivalent.assetString),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(impactEquivalent.amountString,
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
