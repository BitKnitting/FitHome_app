import 'package:fithome_app/common_code/globals.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

Widget electricitySaved(BuildContext context, double percentage) {
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
    // footer: new Text(
    //   "Less",
    //   style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
    // ),
    circularStrokeCap: CircularStrokeCap.round,
    progressColor: Colors.green,
  );
}

Widget impactEquivalent(BuildContext context, int amount, String currentImage) {
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
//
  );
}
