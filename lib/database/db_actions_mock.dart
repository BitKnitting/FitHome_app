import 'package:fithome_app/database/DB_actions.dart';

class DBActionsMock extends DBActions {
  Future getData(String dataPath) async {
    // can't have an async without an await...
    await Future.delayed(Duration(milliseconds: 500));
    // Return dummy values
    var values;
    if (dataPath.contains('insights')) {
      values = {
        'daily_baseline': 21.0,
        'current_average': 19.8,
        'leakage_baseline': 161.0
      };
    }

    return values;
  }
}
