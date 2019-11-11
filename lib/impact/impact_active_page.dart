import 'package:fithome_app/common_code/globals.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'energy_plot/energy_plot.dart';
import 'impact_page.dart';
import 'impact_stream.dart';
import 'impact_widgets.dart';

class ImpactActivePage extends ImpactPage {
  ImpactActivePage({@required this.monitorName});
  final String monitorName;
  final Logger log = Logger('impact_active_page.dart');
  @override
  Widget buildContentSection(BuildContext context) {
    return Stack(
      children: <Widget>[
        // Putting at a height that will "max out" the flex room given by parent.
        Container(height: 2000, child: _impactSection(context)),
      ],
    );
  }

  @override
  Widget setTitle(BuildContext context) {
    return (Text('Active'));
  }

  @override
  Widget buildPlotSection(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.grey[300],
        child: EnergyPlot(monitorName: monitorName),
        alignment: Alignment(0.0, 0.0),
      ),
    );
  }

  Widget _impactSection(BuildContext context) {
    return StreamBuilder(
        // A path to one of the image assets has been put in the impactImages Stream
        stream: ImpactImages().stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              return Stack(children: <Widget>[
                ImpactImage(image: snapshot.data),
                _buildContentOverlay(context, snapshot.data),
              ]);
            } else {
              return Center(child: CircularProgressIndicator());
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  Widget _buildContentOverlay(BuildContext context, String image) {
    return Positioned(
      bottom: 0,
      child: Container(
          height: 100,
          width: MediaQuery.of(context).size.width,
          color: Colors.white54,
          // margin: EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _electricitySaved(context, .5),
              _impactEquivalent(context, 5, image),
            ],
          )),
    );
  }

  Widget _electricitySaved(BuildContext context, double percentage) {
    return CircularPercentIndicator(
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
    );
  }

  Widget _impactEquivalent(
      BuildContext context, int amount, String currentImage) {
    String _assetString = 'assets/impactImages/icons/';
    String _textString;
    // The category is in the URL being used.
    if (currentImage.contains(impactTree)) {
      _assetString += 'trees_icon.png';
      _textString = amount.toString() + ' trees';
    } else if (currentImage.contains(impactOil)) {
      _assetString += 'oil_icon.png';
      _textString = amount.toString() + ' barrels';
    } else {
      _assetString += 'money_icon.png';
      _textString = '\$' + amount.toString();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.asset(_assetString),
        Text(
          _textString,
          style: Theme.of(context).textTheme.subhead,
        ),
      ],
    );
  }
}
