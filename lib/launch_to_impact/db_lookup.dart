import 'dart:async';

import 'package:firebase_database/firebase_database.dart';

class Zips {
  List<int> zipList;

  Zips.fromJson(String key, List parsedJson) {
    //var zipsFromJson = parsedJson[key];
    zipList = List<int>.from(parsedJson);
    zipList.removeWhere((value) => value == null);
    print(zipList);
    // print(data['01']);
    // String test = data['01'];
  }
}

class ZipCodes {
  Future<List<String>> getZipCodes({bool test = true}) async {
    if (test) {
      return ['98033', '92122', 'other'];
    } else {
      DataSnapshot zips =
          await FirebaseDatabase.instance.reference().child('zipcodes').once();
      List<String> zipCodes = List<String>.from(zips.value);
      zipCodes.removeWhere((value) => value == null);
      return zipCodes;

    }
  }
}
