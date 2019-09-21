import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  //**************************************************************************
  // getValue
  // returns null if the value is not in Shared Preferences.
  //**************************************************************************
  Future<String> getValue(String key) async {
    String value;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Check to see if the key exists.  If not, return an empty string.
    if (prefs.containsKey(key)) {
      value = prefs.getString(key);
    }

    return value;
  }

  //**************************************************************************
  // setKey
  //**************************************************************************
  Future<void> setKey(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  //**************************************************************************
  // isInLocalStore
  // check if the email and password are stored in Shared Preferences.
  //**************************************************************************
  Future<bool> isInLocalStore(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(key)) {
      return true;
    }
    return false;
  }

  Future<bool> clear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool prefsCleared = await prefs.clear();
    return (prefsCleared);
  }
}
