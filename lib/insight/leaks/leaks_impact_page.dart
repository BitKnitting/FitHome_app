import 'package:fithome_app/common_code/form_submit_button.dart';
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
    return Stack(
      children: <Widget>[
        StreamBuilder(
            stream: ImpactImages().stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  return Stack(children: <Widget>[
                    ImpactImage(image: snapshot.data),
                  ]);
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }),
        _buildContentOverlay(context, insights),
      ],
    );
  }

  //************************************************************************************** */
  Widget _buildContentOverlay(BuildContext context, Map insights) {
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
              child: _showPercentTotalLeakage(context, insights),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _showDrippingFawcet(context),
                  Text('hello'),
                  Text('hello'),
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

  Widget _showPercentTotalLeakage(BuildContext context, Map insights) {
    double percentTotalLeakage = _calcPercentTotalLeakage(insights);
    return Align(
      alignment: Alignment.topCenter,
      child: Text(
        percentTotalLeakage.toString() + "% of Total Electricity",
        style: Theme.of(context).textTheme.subhead,
      ),
    );
  }

  //*TODO handle errors.
  double _calcPercentTotalLeakage(Map insights) {
    double leakageBaselineKWh = insights['leakage_baseline'] / 1000.0 * 24;

    return leakageBaselineKWh / insights['daily_baseline'] * 100;
  }

  Widget _showDrippingFawcet(context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        width: ContentOverlayHeight - 30,
        height: ContentOverlayHeight - 50,
        // margin: EdgeInsets.only(top: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Align(
              alignment: Alignment.topRight,
              child: Container(
                  width: 80,
                  height: 85,
                  // margin: EdgeInsets.only(right: 17),
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                          left: 0,
                          right: 0,
                          child: Image.asset(
                              'assets/insightsImages/drippingFaucet.png')),
                      Positioned(
                          right: 25,
                          bottom: 5,
                          child: Text(
                            '37w',
                            style: Theme.of(context).textTheme.subhead,
                          )),
                    ],
                  )),
            ),
            Expanded(
                child: Text(
              '327 kWh/year',
              style: Theme.of(context).textTheme.subhead,
              textAlign: TextAlign.right,
            )),
          ],
        ),
      ),
    );
  }
}
