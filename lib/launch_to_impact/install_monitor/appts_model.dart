//
// This code returns the appointments map that is used by TableCalendar
//
import 'package:firebase_database/firebase_database.dart';
import 'package:fithome_app/database/DB_model.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import '../member_model.dart';

class Appointments {
  // The member's uid (Firebase assigns to account).  Retrieved from the member provider.
  String _uid;
  final Logger log = Logger('appts_model.dart');
  String _zipCode = '';

  //* Used across the methods. String = electrician's name.

// Example holidays - not using holidays.
  // Map<DateTime, List> get holidays {
  //   return ({
  //     DateTime(2019, 1, 1): ['New Year\'s Day'],
  //     DateTime(2019, 1, 6): ['Epiphany'],
  //     DateTime(2019, 2, 14): ['Valentine\'s Day'],
  //     DateTime(2019, 4, 21): ['Easter Sunday'],
  //     DateTime(2019, 4, 22): ['Easter Monday'],
  //   });
  // }
  //**************************************************************************
  //* getCalendarDateTimes is called by the UI.
  // The TableCalendar UI relies on appoints being of the format of a map
  // where the key is the DateTime.  This is followed by a list of Strings.
  // Each String in the list is an appointment time.
  //**************************************************************************
  Future<Map<DateTime, List>> getCalendarDateTimes(BuildContext context) async {
    Map<DateTime, String> _installTimes = Map<DateTime, String>();
    // Here's where we will set the uid for the other method/functions
    final _member = Provider.of<Member>(context);
    // I keep forgetting to do this...so obviously this isn't the best way to fill in
    // stuff stored locally.
    await _member.getValues();
    _uid = _member.id;
    Map<DateTime, List> apptList = Map<DateTime, List>();
    // Make sure we have the _installTimes Map.
    // The _installTimes Map has an appt's DateTime as the key and the electrician's name
    // as the value.  We'll go through each date time and put the time in a  list with the date.
    _installTimes = await getInstallTimes();
    if (_installTimes == null) {
      return null;
    }
    // Create a list of the datetimes.
    List<DateTime> dtList = List<DateTime>();
    _installTimes.forEach((key, value) {
      dtList.add(key);
    });
    // Sort the list.
    dtList.sort();
    // Make the apptList in the way Table Calendar wants it.
    // Start with the earliest date.
    int currentApptMonth = dtList[0].month;
    int currentApptDay = dtList[0].day;
    int currentApptYear = dtList[0].year;
    List<String> apptTimes = List<String>();
    for (DateTime dt in dtList) {
      // If the year, month, or day has changed, they'll be a new entry in the apptList since appointments are shown on the day.a
      if (dt.year != currentApptYear ||
          dt.month != currentApptMonth ||
          dt.day != currentApptDay) {
        // If the date is different, add the list of appointments to the date.
        apptList[DateTime(currentApptYear, currentApptMonth, currentApptDay)] =
            apptTimes;
        // Start on the new date.
        apptTimes = [];
        currentApptDay = dt.day;
        currentApptMonth = dt.month;
        currentApptYear = dt.year;
        // We're reading in an appointment that is at a new date, so we need to add it to the list.
        apptTimes.add(
            dt.hour.toString() + ":" + dt.minute.toString().padRight(2, '0'));
      } else {
        apptTimes.add(
            dt.hour.toString() + ":" + dt.minute.toString().padRight(2, '0'));
      }
    }
    if (apptTimes.isNotEmpty) {
      apptList[DateTime(currentApptYear, currentApptMonth, currentApptDay)] =
          apptTimes;
    }
    return apptList;
  }

  //**************************************************************************

  //**************************************************************************

  Future<Map<DateTime, String>> getInstallTimes() async {
    Map<DateTime, String> _installTimes = Map<DateTime, String>();
    // Here we assume this method gets called multiple times...  If this is the case, we return
    // the list of available appts without going back to Firebase.
    if (_installTimes.isNotEmpty) {
      return _installTimes;
    }
    // Electrician availability is localized to a zip code.  We need the member's zip code.
    _zipCode = await _getZipCode();
    Map _installTimesInDB = await _getInstallTimes();
    if (_installTimesInDB == null) {
      return null;
    }

    _installTimes = await _deleteOldAppts(_installTimesInDB);
    return (_installTimes);
  }

  //**************************************************************************
  /// Get the member's zip code from the database.
  //**************************************************************************
  Future<String> _getZipCode() async {
    String _zipcode =
        await DBHelper().getData(dbRef: DBRef.memberZipcodeRef(_uid));
    return _zipcode;
  }

  //**************************************************************************
  /// Get the available appointments for this zip code from the database.
  //**************************************************************************
  Future<Map> _getInstallTimes() async {
    Map _installTimes = await DBHelper()
        .getData(dbRef: DBRef.availableApptsZipCodeRef(_zipCode));
    if (_installTimes == null) {
      log.severe('!!!Error: available_appointments node not in the db.');
      return null;
    }
    return _installTimes;
  }

  //**************************************************************************
  // Check if the available_times node in Firebase has any install entries.
  //**************************************************************************
  Future<Map<DateTime, String>> _deleteOldAppts(Map _installTimesInDB) async {
    Map<DateTime, String> _installTimes = Map<DateTime, String>();
    // Create a variable to hold the keys of the datetimes that have already passed.
    // We'll want to delete these from Firebase.
    List<String> keyList = List<String>();
    // Get the available date/times and electrician names from Firebase RT
    _installTimesInDB.forEach(
      (key, value) {
        try {
          DateTime dt = DateTime.parse(value["datetime"]);
          // If the datetime has passed, add the key to the key list.
          // This appointment will be deleted.
          if (dt.isBefore(DateTime.now())) {
            log.info(
                'Removing $dt under key: $key because the date/time is in the past.');
            keyList.add(key);
            // The appointment time is in the future.  Add it to the map
            // of install times.
          } else {
            _installTimes[dt] = value['name'];
          }
        } catch (e) {
          log.warning(
              'Could not use the datatime in available_appointments.  Error: $e');
        }
      },
    );
    // Delete any appointments that are past due.
    if (keyList.isNotEmpty) {
      keyList.forEach((key) async {
        await DBHelper()
            .removeData(dbRef: DBRef.availableApptZipCodeRef(_zipCode, key));
      });
    }
    // _installTimes should be empty if all appointments were in the past...
    return _installTimes;
  }

  //**************************************************************************
  Future<bool> setAppt(
      BuildContext context, DateTime day, String timeStr) async {
    //* Convert the variables passed in into a datetime.  This will be the datetime
    //* that the homeowner wants to have the electrician install the monitor.
    List<String> hourMinutesList = timeStr.split(":");
    DateTime apptDateTime = DateTime(day.year, day.month, day.day,
        int.parse(hourMinutesList[0]), int.parse(hourMinutesList[1]), 0);
    log.info('Setting monitor install appointment time/date to: $apptDateTime');
    //* Set the install_datetime under the member's uid entry.  Also set the
    //* electrician name under member's uid -> monitor node.
    bool canUpdate = await _updateMonitorInstallInfo(context, apptDateTime);
    if (!canUpdate) {
      return false;
    }

    return true;
    //*TODO: The modification of Firebase RT should cause the backend to trigger sending a text message to the electrician as well as email and text to member services, enter task in trello????
    //*TODO: Another trigger should fire 24 hours before and send sms to homeowner, member services, electrician notifying of upcoming appointments.
  }

  //************************************************************ */
  // The homeowner may get a reminder when the appointment is scheduled.
  //************************************************************ */
  Future<String> getAppt(BuildContext context) async {
    var _appt;
    final member = Provider.of<Member>(context);
    await member.getValues();
    String uid = member.id;
    if (uid == null) {
      log.severe(
          '!!! Error.  The member id is null.  There should be one if this method is called.');
    }
    _appt =
        await DBHelper().getData(dbRef: DBRef.memberInstallDateTimeRef(uid));
    if (_appt == null) {
      log.severe(
          'Tried to get the install_datetime.  Firebase returned null.  There should have been an install_datetime.');
    }
    return _appt;
  }

  //************************************************************ */
  /// Update the Member's monitor install info.  Updating appt info
  /// moves the appointment info (electrician name and date/time of the
  /// appointment) under the member's node AND deleting the appointment
  /// from the available_appointments.
  //************************************************************ */
  Future<bool> _updateMonitorInstallInfo(
      BuildContext context, DateTime apptDateTime) async {
    final member = Provider.of<Member>(context);
    String apptDateTimeString = apptDateTime.toIso8601String();
    String electrician;
    String uid = await member.id;
    if (_zipCode.isEmpty) {
      _zipCode = await _getZipCode();
    }

    var _installTimes = await _getInstallTimes();

    //* Get the electrician's name associated with the install time.

    _installTimes.forEach(
      (key, value) {
        if (DateTime.parse(value['datetime']) == apptDateTime) {
          log.info(
              'the appointment datetime ($apptDateTime) passed in matched a datetime in Firebase RT.');
          electrician = value['name'];
          // WE're at te available_times record that we are reserving for the member.  Since we have this info, now
          // is a good time to delete it from the available_times node.
          _deleteAppt(key, value);
        }
      },
    );
    //* The electrician's name shouldn't be null.
    if (electrician == null) {
      log.severe(
          '!!!ERROR: The electrician name is null.  The name should not be null.');
      return false;
    }

    //* Store the install_datetime and electrician in Firebase under the member's monitor node.
    await DBHelper().updateData(
        dbRef: DBRef.memberMonitorRef(uid),
        data: {'install_datetime': apptDateTimeString});
    await DBHelper().updateData(
        dbRef: DBRef.memberMonitorRef(uid), data: {'electrician': electrician});

    log.info(
        'Updated member $uid install date_time to $apptDateTimeString, and electrician to $electrician under the monitor node.');
    return true;
  }

  /********************************************************************* */
  //*  An appointment - apptDateTime = has been scheduled.  Remove it from the
  //*  available_times node.
  /********************************************************************* */
  void _deleteAppt(dynamic key, dynamic value) async {
    if (_zipCode.isEmpty) {
      _zipCode = await _getZipCode();
    }
    DBHelper().removeData(dbRef:DBRef.availableApptZipCodeRef(_zipCode, key));
      log.info(
          'Removed the date/time ${value['datetime']} from available_times in Firebase.');
  }
}
