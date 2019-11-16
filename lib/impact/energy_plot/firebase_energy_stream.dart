import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:fithome_app/database/DB_model.dart';

import 'energy_reading.dart';
//*TODO: Put in similar code to what is in MockEnergyStream once
// real results are being used.

class FirebaseEnergyStream  {
  Future startReadingsStream(
      // Data is randomly generated...
      // The monitorName is not used.
      String monitorName,
      void onData(var reading)) async {
    final DatabaseReference _readingsRef = DBRef.readingsRef(monitorName);
    // We're setting up our stream subscription.  The challenge is we want
    // only the latest readings.  Whereas onChildAdded will return all readings.
    // To limit to the latest, we first get the last two readings in Firebase.
    var data = await DBHelper().getData(dbRef: _readingsRef.limitToLast(2));
    // Then we get the earlier key and set a query for readings to start
    // At this entry.
    Query _query = _readingsRef.orderByKey().startAt(data.keys.first);
    _query.onChildAdded.listen((event) {
      var watts = event.snapshot.value["P"];
      DateTime datetime = DateTime.fromMillisecondsSinceEpoch(
          int.parse(event.snapshot.key) * 1000);
      if (watts == null) {
        onData(EnergyReading(dateTime: DateTime.now(), watts: 0));
      } else {
        onData(EnergyReading(dateTime: datetime, watts: watts));
      }
    });
  }

  void closeReadingsStream() {}
}
