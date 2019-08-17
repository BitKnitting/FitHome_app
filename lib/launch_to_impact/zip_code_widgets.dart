//*TODO: ValueNotifier of good zipcode to pass to parent.
//*TODO: if good zipcode chosen, delete/hide  "Start by choosing your zipcode"
//*TODO: Platform alert dialog if other
//*TODO: All other entry fields disabled until a good zipcode is chosen.
import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

final Logger log = Logger('zip_code_widgets.dart');

class ZipCodes {
  Future<List<String>> getZipCodes({bool test = true}) async {
    if (test) {
      return ['Please choose', '98033', '92122', 'other'];
    } else {
      DataSnapshot zips =
          await FirebaseDatabase.instance.reference().child('zipcodes').once();
      List<String> zipCodes = List<String>.from(zips.value);
      zipCodes.removeWhere((value) => value == null);
      return zipCodes;
    }
  }
}

class ZipCode extends StatefulWidget {
  @override
  _ZipCodeState createState() => _ZipCodeState();
}

class _ZipCodeState extends State<ZipCode> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: Column(
        children: <Widget>[
          Flexible(child: _zipDropDown()),
        ],
      ),
    );
  }

  String _zipCodeValue = '';
  Widget _zipDropDown() {
    void _updateState(String newZipValue) {
      setState(() {
        _zipCodeValue = newZipValue;
      });
    }

    return FutureBuilder(
      //future: FirebaseDatabase.instance.reference().child("zipcodes").once(),
      future: ZipCodes().getZipCodes(test: true),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            //*TODO: Test with zipcodes removed from Firebase
            //*TODO: Handle snapshot error.
          }
          if (snapshot.hasData) {
            List<String> zipCodes = snapshot.data;
            log.info('snapshot has zipcodes: $zipCodes');

            return DropdownButton<String>(
              items: zipCodes.map((String dropDownStringItem) {
                return DropdownMenuItem<String>(
                  value: dropDownStringItem,
                  child: Text(
                    dropDownStringItem,
                    style: TextStyle(fontSize: 20),
                  ),
                );
              }).toList(),
              onChanged: (String newValueSelected) {
                _updateState(newValueSelected);
                _zipCodeValue = newValueSelected;
              },
              value: _zipCodeValue.isEmpty ? zipCodes[0] : _zipCodeValue,
            );
          } else {
            return _errorDialog();
          }
        } else {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  Widget _errorDialog() {
    log.info('error getting zip codes.  Connection done, but hasData = false.');
    return Text(
        'error getting zip codes.  Connection done, but hasData = false.');
  }
}
