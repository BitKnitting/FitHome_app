import 'package:firebase_database/firebase_database.dart';
import 'package:logging/logging.dart';

///****************************************************************************** */
/// All database references are maintained in this file.
/// This way we can quickly see all the database paths being used by the app.
class DBRef {
  static DatabaseReference rootRef = FirebaseDatabase.instance.reference();
  static DatabaseReference readingsRef(String monitorName) =>
      rootRef.child('readings').child(monitorName);
  static DatabaseReference memberRef(String uid) =>
      rootRef.child('members').child(uid);
  static DatabaseReference memberMonitorRef(String uid) =>
      rootRef.child('members').child(uid).child('monitor');
}

class DBHelper {
  Logger log = Logger('DB_model.dart');
  ///*************************************************************************** */
  /// Utility method used when writing data to Firebase.

  Future<bool> setData(
      {DatabaseReference dbRef, Map<String, dynamic> data}) async {
    try {
      await dbRef.set(data);
      return true;
    } catch (e) {
      log.info('Error: ${e.message} .');
      return false;
    }
  }
}
