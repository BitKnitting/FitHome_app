//*************************************************************************** */

// By using the Member class, our abstract AuthBase could be built from other authentication dbs.

import 'package:fithome_app/common_code/prefs_service.dart';
import 'package:fithome_app/database/DB_model.dart';
import 'package:logging/logging.dart';
import 'package:fithome_app/common_code/globals.dart';

class Member {
  // From https://dart.dev/guides/language/effective-dart/usage
  // If you make a parameter optional but don’t give it a default value,
  // the language implicitly uses null as the default
  String _email;
  String _password;
  String _id;

  /// Gets the member properties stored in the local store.  We store these
  /// properties so that the member can transparently sign in once an account
  /// has been created for the homeowner.
  getValues() async {
    _email = await Prefs().getValue(emailKey);
    _password = await Prefs().getValue(passwordKey);
    _id = await Prefs().getValue(uidKey);
  }

  /// Properties stored under the members/uid node in Firebase.
  Map<String, dynamic> toJsonStart(
          {String address,
          String zip,
          String name,
          String phone,
          String email}) =>
      {
        "address": address,
        "zipcode": zip,
        "email": email,
        "name": name,
        "phone": phone,
        "status": "start",
        "start_timestamp": {".sv": "timestamp"},
      };

  Logger log = Logger('member_model.dart');
  //**************************************************************************
  // email property
  //**************************************************************************
  get email {
    return _email;
  }

  // Lazy saving since Prefs().setKey() is async.
  set email(String emailString) {
    _email = emailString;
    Prefs().setKey(emailKey, emailString);
  }

  //**************************************************************************
  // password property
  //**************************************************************************
  get password {
    return _password;
  }

  set password(String pwd) {
    _password = pwd;
    Prefs().setKey(passwordKey, pwd);
  }

  //**************************************************************************
  // id property
  //**************************************************************************
  Future<void> saveUid(String uid) async {
    _id = uid;
    await Prefs().setKey(uidKey, uid);
  }

  get id {
    return _id;
  }

  //**************************************************************************
  /// Clear all properties from the local store.
  //**************************************************************************
  Future<bool> clear() async {
    return await Prefs().clear();
  }
  //**************************************************************************
  /// Create a member record within the members node of Firebase.
  /// We put the homeowner's name, address, zip code, phone into the member
  /// record.  This info was entered by the homeowner. and the name of
  /// the monitor that was assigned to the user.  The homeowner entered this
  /// info on the StartTrainingPzge.
  //**************************************************************************

  Future<bool> createRecord({name, address, zip, phone, monitor}) async {
    String _email = email;
    Map userRecordJson = Member().toJsonStart(
        email: _email, name: name, address: address, zip: zip, phone: phone);
    bool dbActionWorked = await DBHelper()
        .setData(dbRef: DBRef.memberRef(id), data: userRecordJson);
    if (!dbActionWorked) {
      return false;
    }
    dbActionWorked = await DBHelper()
        .setData(dbRef: DBRef.memberMonitorRef(id), data: {'name': monitor});
    if (!dbActionWorked) {
      return false;
    }
    return true;
  }
}
