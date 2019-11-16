import 'package:fithome_app/common_code/globals.dart';
import 'package:fithome_app/database/db_actions_mock.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'energy_plot/energy_plot.dart';
import 'impact_page.dart';
import 'impact_stream.dart';
import 'impact_utils.dart';


const ContentOverlayHeight = 140.0;

class ImpactActivePage extends ImpactPage {
  ImpactActivePage({@required this.monitorName});
  final String monitorName;
  final Logger log = Logger('impact_active_page.dart');
  final DBActionsMock dbActions = DBActionsMock();
 
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


  Widget setTitle(BuildContext context) {
    return (Text('Active'));
  }


  Widget buildActionSection(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.grey[300],
        child: EnergyPlot(monitorName: monitorName),
        alignment: Alignment(0.0, 0.0),
      ),
    );
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

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _electricitySaved(context, insights),
              _dailyAverage(context, insights),
              _impactEquivalent(context, image, insights),
            ],
          )),
    );
  }

  //************************************************************************************** */
  Widget _electricitySaved(BuildContext context, Map insights) {
    double percentage =
        1 - insights['current_average'] / insights['daily_baseline'];
    String textString = percentage < 0.0 ? 'more' : 'less';
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CircularPercentIndicator(
          radius: 70.0,
          lineWidth: 8.0,
          animation: true,
          percent: percentage,
          animateFromLastPercent: true,
          center: Text(
            (percentage * 100).toInt().toString() + '%',
            style: Theme.of(context).textTheme.subhead,
          ),
          circularStrokeCap: CircularStrokeCap.round,
          progressColor: Colors.green,
        ),
        Container(
          width: 100,
          alignment: Alignment.center,
          child: Text(
            textString,
            style: Theme.of(context).textTheme.subhead,
          ),
        ),
      ],
    );
  }

  //************************************************************************************** */
  // The daily average ui shows two buttons.  One button has text that shows the initial
  // (baseline) daily average calculated during the learning phase.  The other button shows
  // the past 24 hour's daily average.  It is red if > baseline, green if < baseline, grey if =
  // baseline.
  //************************************************************************************** */

  Widget _dailyAverage(BuildContext context, Map insights) {
    Color dailyAvgButtonColor =
        insights['current_average'] < insights['daily_baseline']
            ? Colors.green
            : Colors.red;
    String baselineAvgString =
        insights['daily_baseline'].toStringAsFixed(2) + ' kWh';
    String dailyAvgString =
        insights['current_average'].toStringAsFixed(2) + 'kWh';
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.end,
        // mainAxisSize: MainAxisSize.max,
        // crossAxisAlignment: CrossAxisAlignment.center,
        // Expanded scales so all will fit within the column.
        children: <Widget>[
          Expanded(
              child: Text('Daily Average',
                  style: Theme.of(context).textTheme.subhead)),
          Expanded(child: _dailyAverageButton(text: baselineAvgString)),
          Expanded(
              child: Container(
            alignment: Alignment.center,
            child: Text(
              'Initial',
              style: Theme.of(context).textTheme.subhead,
            ),
          )),
          Expanded(
              child: _dailyAverageButton(
                  text: dailyAvgString, color: dailyAvgButtonColor)),
          Expanded(
              child: Container(
            alignment: Alignment.center,
            child: Text(
              'Current',
              style: Theme.of(context).textTheme.subhead,
            ),
          )),
        ],
      ),
    );
  }

  Widget _dailyAverageButton({@required String text, Color color}) {
    if (color == null) {
      color = Colors.grey[500];
    }

    return Container(
        child: Center(
            child: Text(text,
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold))),
        height: ContentOverlayHeight / 3,
        width: 100,
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                  color: Colors.black, offset: Offset(2, 2), blurRadius: 5)
            ]));
  }

  
  ///************************************************************************************** */
  /// Here is where we calculate the amount of money and
  /// amount of CO2 (relative to gals of gas, acres of forest,
  /// and barrels of oil).
  /// The conversion numbers (e.g.: .000707..85, etc..) come from
  /// http://bit.ly/374ehUe
  ///************************************************************************************** */
  Widget _impactEquivalent(
      BuildContext context, String currentImage, Map insights) {
    String _assetString = 'assets/impactImages/icons/';
    String _textString;
    double yearlySavingsKWh =
        (insights['daily_baseline'] - insights['current_average']) * 365;
    double _metricTons = .000707 * yearlySavingsKWh;

    // The category is in the URL being used.
    if (currentImage.contains(impactTree)) {
      _assetString += 'trees_icon.png';
      double _amount = _metricTons / .85;
      _textString = _amount.toString() + ' trees';
    } else if (currentImage.contains(impactOil)) {
      _assetString += 'oil_icon.png';
      double _amount = _metricTons / .43;
      _textString = _amount.toStringAsFixed(2) + ' barrels';
    } else if (currentImage.contains(impactMoney)) {
      _assetString += 'money_icon.png';
      //*TBD: Hard coded electricity cost at 13 cents/kWh
      double _amount = yearlySavingsKWh * .13;
      _textString = '\$' + _amount.toStringAsFixed(2);
    } else {
      _assetString += 'gas_icon.png';
      double _amount = _metricTons / .00887;
      _textString = _amount.toStringAsFixed(2) + ' gals';
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.asset(_assetString),
        Container(
          width: 100,
          alignment: Alignment.center,
          child: Text(
            _textString,
            style: Theme.of(context).textTheme.subhead,
          ),
        ),
      ],
    );
  }
}
