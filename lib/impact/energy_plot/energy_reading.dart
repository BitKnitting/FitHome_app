import 'package:firebase_database/firebase_database.dart';

class EnergyReading {
  DateTime dateTime;
  double watts;

  EnergyReading({this.watts, this.dateTime});

  EnergyReading.fromSnapshot(DataSnapshot snapshot) {
    dateTime =
        DateTime.fromMillisecondsSinceEpoch(int.parse(snapshot.key) * 1000);
    watts = snapshot.value["P"];
  }
}
