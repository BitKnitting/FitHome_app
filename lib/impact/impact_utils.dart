import 'package:fithome_app/common_code/globals.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:fithome_app/database/db_actions_mock.dart';

class ImpactImage extends StatelessWidget {
  ImpactImage({@required this.image}) : assert(image != null);
  final String image;
  @override
  Widget build(BuildContext context) {
    AssetImage assetImage = AssetImage(image);
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
}

//************************************************************************************** */
/// Uses an implementation of the abstract base class
/// DBActions to get values from a data store.
/// We have written DBAction class implementation for
/// mock data (dbActionsMock) and Firebase
/// (dbActionsFirebase).
//************************************************************************************** */
Future getImpactValues(String monitorName) async {
  DBActionsMock dbActions = DBActionsMock();
  String dataPath = monitorName + '\\insights';
  Map insights = await dbActions.getData(dataPath);
  return (insights);
}

//************************************************************************************** */
/// Impact images are updated every so many seconds.
/// Information about amount of money saved/lost, CO2 equivalencies
/// will change on the screen based on the impact image.
/// we calculate the amount of money and
/// amount of CO2 (relative to gals of gas, acres of forest,
/// and barrels of oil).
/// The conversion numbers (e.g.: .000707..85, etc..) come from
/// http://bit.ly/374ehUe
//************************************************************************************** */
enum ImpactType { aggregate, leakage }

class ImpactEquivalent {
  String assetString;
  String amountString;
  double leakageBaseline;
  double dailyBaseline;
  double currentAverage;
  ImpactType impactType;
  ImpactEquivalent({
    this.impactType,
  }) : assert(impactType != null);

  getImpactEquivalent(String imageName, Map insights) {
    leakageBaseline = insights['leakage_baseline'];
    dailyBaseline = insights['daily_baseline'];
    currentAverage = insights['current_average'];
    assetString = 'assets/impactImages/icons/';
    double yearlyKWh = 0.0;
    if (impactType == ImpactType.aggregate) {
      yearlyKWh = (dailyBaseline - currentAverage) * 365;
    } else {
      yearlyKWh = leakageBaseline / 1000 * 24 * 365;
    }
    double _metricTons = .000707 * yearlyKWh;
    // The category is in the URL being used.
    if (imageName.contains(impactTree)) {
      assetString += 'trees_icon.png';
      double _amount = _metricTons / .85;
      amountString = _amount.toString() + ' trees';
    } else if (imageName.contains(impactOil)) {
      assetString += 'oil_icon.png';
      double _amount = _metricTons / .43;
      amountString = _amount.toStringAsFixed(2) + ' barrels';
    } else if (imageName.contains(impactMoney)) {
      assetString += 'money_icon.png';
      //*TBD: Hard coded electricity cost at 13 cents/kWh
      double _amount = yearlyKWh * .13;
      amountString = '\$' + _amount.toStringAsFixed(2);
    } else {
      assetString += 'gas_icon.png';
      double _amount = _metricTons / .00887;
      amountString = _amount.toStringAsFixed(2) + ' gals';
    }
  }
}
