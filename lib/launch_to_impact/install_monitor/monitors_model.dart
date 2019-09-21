import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import '../member_model.dart';

class Monitors {
  Logger log = Logger('monitors_model.dart');
  String _monitorFullName;

  //**************************************************************************
  //* IF there is a monitor available in Firebase, get it and change the monitor's
  //* Setting under the available_nmonitors node from true (monitor is available)
  //* to false.
  //* A monitor name is modified to be unique by adding the date to the end of the
  //* monitor name.
  //*TODO: Resetting monitor availability when homeowner ends the challenge.
  //**************************************************************************
  Future<String> makeMonitorName() async {
    String _monitor = await _getAvailableMonitorFromDB();

    if (_monitor == null) {
      log.severe('!!! Error: a monitor is not available');
      return null;
    }
    log.info('Got monitor $_monitor.');
    // We're reserving this monitor for the homeowner.  So make it unavailable
    // in the list of available_monitors in Firebase.
    _setUnavailable(_monitor);
    //* Add -<mmddyyyy> to monitor name.
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('MMddyyyy').format(now);
    _monitorFullName = _monitor + '-' + formattedDate;
    return _monitorFullName;
  }

  //******************************************************************** */
  //* Returns true if there is a monitor within available_monitors that says
  //* It is available.
  //******************************************************************** */
  Future<bool> checkAvailability() async {
    String monitor = await _getAvailableMonitorFromDB();
    if (monitor == null) {
      return false;
    } else {
      return true;
    }
  }

  //******************************************************************** */
  //* Once a homeowner has scheduled an appointment, the monitor can be
  //* in UI states:
  //* - Start - Homeowner info has been entered, but monitor installation time has not been set.
  //* - Waiting for monitor installation.
  //* - Collecting baseling readings.
  //* - Active in FitHome training.
  //* With this method, we can return the monitor's state.
  //******************************************************************** */
  Future<String> getStatus(BuildContext context) async {
    // We need to get the homeowner's uid.
    final member = Provider.of<Member>(context);
    await member.getValues();
    String id = member.id;
    if (id == null) {
      log.severe(
          '!!! Error.  The member id is null.  There should be one if this method is called.');
      return null;
    } else {
      log.info('The member id is: $id');
    }
    try {
      DataSnapshot statusDB = await FirebaseDatabase.instance
          .reference()
          .child('members')
          .child(id)
          .child('status')
          .once();

      log.info('The monitor status is: ${statusDB.value}');
      return statusDB.value;
    } catch (e) {
      log.info(
          '!!!Error: ${e.message} On attempting to get the monitor status!!!');
      return null;
    }
  }

  //**************************************************************************
  //* Set the monitor's value to 'false' so it is no longer seen as available.
  //**************************************************************************
  void _setUnavailable(String monitor) async {
    try {
      await FirebaseDatabase.instance
          .reference()
          .child('available_monitors')
          .update({monitor: false});
      log.info('Updated $monitor availability to false in Firebase.');
    } catch (e) {
      log.info(
          '!!!Error: ${e.message} On attempting to set monitor $monitor to false in Firebase.!!!');
      return;
    }
  }

  //******************************************************************** */
  //* Grab the list of monitors and see if any are available.  If there is one
  //* available, return the monitor name.  If not, return null.
  //******************************************************************** */
  Future<String> _getAvailableMonitorFromDB() async {
    // Go through monitors and find one that is available.  A monitor is available
    // if it's name (which is the key) is equal to 'true'.
    String _monitor;

    DataSnapshot _monitorsInDB;
    try {
      _monitorsInDB = await FirebaseDatabase.instance
          .reference()
          .child('available_monitors')
          .once();
    } catch (e) {
      log.severe('Error!  Message: $e');
      return null;
    }

    if (_monitorsInDB.value == null) {
      log.severe(
          '!!!Error the node available_monitors does not exist in Firebase.');
      return null;
    }

    for (String key in _monitorsInDB.value.keys) {
      if (_monitorsInDB.value[key] == true) {
        _monitor = key;
        break;
      }
    }
    return _monitor;
  }

//******************************************************************** */
  //* Get the monitor name from Firebase, or return the name if we already
  // * have it.
  //******************************************************************** */

  // Future<String> getMonitorName(BuildContext context) async {
  //   if (_monitorFullName?.isEmpty ?? true) {
  //     return await _getMonitorName(context);
  //   } else {
  //     return _monitorFullName;
  //   }
  // }
  //******************************************************************** */
  //* Internal method to get the monitor name from Firebase.
  //******************************************************************** */
  // Future<String> _getMonitorName(BuildContext context) async {
  //   final member = Provider.of<Member>(context);
  //   String id = await member.id;
  //   if (id == null) {
  //     log.severe(
  //         '!!! Error.  The member id is null.  There should be one if this method is called.');
  //   }
  //   DataSnapshot _monitorNameDB;
  //   try {
  //     _monitorNameDB = await FirebaseDatabase.instance
  //         .reference()
  //         .child('members')
  //         .child(id)
  //         .child('monitor')
  //         .child('name')
  //         .once();
  //   } catch (e) {
  //     log.severe('Error!  Message: $e');
  //     return null;
  //   }
  //   if (_monitorNameDB == null) {
  //     log.severe(
  //         'Tried to get the monitor name.  Firebase returned null.  There should have been a monitor name.');
  //   }
  //   return _monitorNameDB.value;
  // }
}
