import 'package:firebase_database/firebase_database.dart';
import 'package:meta/meta.dart';
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
  static DatabaseReference memberInstallDateTimeRef(String uid) => rootRef
      .child('members')
      .child(uid)
      .child('monitor')
      .child('install_datetime');
  static DatabaseReference memberZipcodeRef(String uid) =>
      rootRef.child('members').child(uid).child('zipcode');

  static DatabaseReference monitorsAvailableRef() =>
      rootRef.child('available_monitors');
  static DatabaseReference memberMonitorStatusRef(String uid) =>
      rootRef.child('members').child(uid).child('monitor').child('status');
  static DatabaseReference availableApptsZipCodeRef(String zipcode) =>
      rootRef.child('available_appointments').child(zipcode);
  static DatabaseReference availableApptZipCodeRef(
          String zipcode, String apptNumber) =>
      rootRef.child('available_appointments').child(zipcode).child(apptNumber);
}

class DBHelper {
  Logger log = Logger('DB_model.dart');

  ///*************************************************************************** */
  /// Utility method used when writing data to Firebase.

  Future<bool> setData(
      {@required DatabaseReference dbRef,
      @required Map<String, dynamic> data}) async {
    try {
      await dbRef.set(data);
      return true;
    } catch (e) {
      log.info('Error: ${e.message} .');
      return false;
    }
  }

  Future<bool> updateData(
      {@required DatabaseReference dbRef,
      @required Map<String, dynamic> data}) async {
    try {
      await dbRef.update(data);
      return true;
    } catch (e) {
      log.info('Error: ${e.message} .');
      return false;
    }
  }

  ///*************************************************************************** */
  /// Utility method used when getting data from Firebase.
  Future getData({@required dbRef}) async {
    DataSnapshot _snapshot;
    try {
      _snapshot = await dbRef.once();
    } catch (e) {
      log.info('Error: ${e.message} .');
      return null;
    }
    return _snapshot.value;
  }

  Future removeData({@required dbRef}) async {
    await dbRef.remove();
  }
}
