class EnergyReading {
  DateTime dateTime;
  int watts;

  EnergyReading({this.watts, this.dateTime});
  EnergyReading.fromJson(Map<String, dynamic> data)
      : dateTime = data['dateTime'],
        watts = data['watts'];
}
