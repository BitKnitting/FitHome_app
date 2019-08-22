import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:fithome_app/launch_to_impact/zipcode_ticket.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';


final Logger log = Logger('zip_code_widgets.dart');
const otherString = 'other';

class ZipCodes {
  Future<List<String>> getZipCodes({bool test = true}) async {
    if (test) {
      return ['Please choose', '98033', '92122', otherString];
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
  final zipCodeString = ValueNotifier<String>('');
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

  Widget _zipDropDown() {
    List<String> zipCodes;

    void _updateState(String newZipValue) {
      setState(() {
        // If the chosen zipcode is 'other', it means the user isn't within a supported region.
        // A supported region has an electrician available that can install the monitor.
        // However, we will want exceptions (friends, family, testers).  These folks will be
        // given a code to enter.  Once they enter the code, they must write in their zip code.
        // Once they do that, the logic goes to filling the form.

        if (newZipValue == otherString) {
          // Dialog box.  Input = code.  This enables zip code entry text field.
          //_otherZipDialog();
          Navigator.of(context).push(MaterialPageRoute(
              fullscreenDialog: true,
              builder: (context) => ZipCodeTicketPage()));
        }
        // Zipcodestring is a value notifier used by the parent.  Don't pass back non-zipcodes.
        if (newZipValue != zipCodes.first || newZipValue != zipCodes.last) {
          widget.zipCodeString.value = newZipValue;
        }
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
            zipCodes = snapshot.data;
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
              },
              value: widget.zipCodeString.value.isEmpty
                  ? zipCodes[0]
                  : widget.zipCodeString.value,
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
