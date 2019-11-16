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
 