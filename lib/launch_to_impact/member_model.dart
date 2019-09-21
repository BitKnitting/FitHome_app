//*************************************************************************** */

// By using the Member class, our abstract AuthBase could be built from other authentication dbs.
import 'package:firebase_database/firebase_database.dart';
import 'package:fithome_app/common_code/prefs_service.dart';
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
  // saveUid property
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
  /// Create a member record within the members node of Firebase.  The member
  /// node is the member's uid.
  /// We put the homeowner's name, address, zip code, phone, and the name of
  /// the monitor that was assigned to the user.  The homeowner entered this
  /// info on the StartTrainingPzge.
  //**************************************************************************

  Future<bool> createRecord({name, address, zip, phone, monitor}) async {
    // For the member that has the uid,
    // Note: push() generates a document id.  set() does not.
    String memberID = await id;
    String _email = await email;
    Map userRecordJson = Member().toJsonStart(
        email: _email, name: name, address: address, zip: zip, phone: phone);
    try {
      await FirebaseDatabase.instance
          .reference()
          .child('members')
          .child(memberID)
          .set(userRecordJson);
    } catch (e) {
      log.info('Error: ${e.message} .');
      return false;
    }
    try {
      await FirebaseDatabase.instance
          .reference()
          .child('members')
          .child(memberID)
          .child('monitor')
          .set({'name': monitor});
    } catch (e) {
      log.info('Error: ${e.message} .');
      return false;
    }

    return true;
  }

  Future<Map> getRecord() async {
    if (_id == null) {
      // UhOh = the member should be logged in.  This means the member's UID should be available...but it isn't.
      log.severe('!!!Error Member ID is null');
      return null;
    }

    try {
      DataSnapshot memberInfoDB = await FirebaseDatabase.instance
          .reference()
          .child('members')
          .child(_id)
          .once();
      return (memberInfoDB.value);
    } catch (e) {
      log.info('Error: ${e.message} .');
    }
    return null;
  }
}
