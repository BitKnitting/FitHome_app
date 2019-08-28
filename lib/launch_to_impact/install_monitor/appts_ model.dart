//
// This code returns the appointments map that is used by TableCalendar
//
import 'package:firebase_database/firebase_database.dart';
import 'package:logging/logging.dart';

class Appointments {
  Logger log = Logger('appts_model.dart');
  Map<DateTime, List> _installTimes = Map<DateTime, List>();

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
  // The Map of appointments - CALL THIS DURING LAUNCH SEQUENCE TO MAKE SUre
  // THERE ARE APPOINTMENTS.
  //**************************************************************************
  Future<Map<DateTime, List>> getInstallTimes() async {
    // return await installTimes;
    return await realinstallTimes();
  }

  //**************************************************************************
  // installTimes should have already been retrieved.
  //**************************************************************************
  get installTimes {
    return _installTimes;
  }

  Future<Map<DateTime, List>> realinstallTimes() async {
    if (_installTimes.isNotEmpty) {
      return _installTimes;
    }
    DataSnapshot installTimesInDB;

    // Get the available times from Firebase RT
    try {
      installTimesInDB = await FirebaseDatabase.instance
          .reference()
          .child('available_times')
          .once();
    } catch (e) {
      log.severe('Error!  Message: $e');
      return null;
    }
    Map<dynamic, dynamic> vals = installTimesInDB.value;
    List<DateTime> dtList = List<DateTime>();
    vals.forEach(
      (key, value) {
        try {
          DateTime dt = DateTime.parse(value["datetime"]);
          // Appointments are grouped by day. I.e.: There can be multiple appointments on a day.
          dtList.add(dt);
        } catch (e) {
          log.warning(
              'Could not use the datatime in available_times.  Error: $e');
        }
      },
    );
    // Now that all the available datetimes have beenb added to the list of datetimes, sort the list.
    dtList.sort();
    // Now we can figure out what times go with what date and build the installTimes map.
    int currentApptMonth = dtList[0].month;
    int currentApptDay = dtList[0].day;
    int currentApptYear = dtList[0].year;
    List<String> apptTimes = List<String>();
    // The datetimes have been sorted, now set up the appointments.
    for (DateTime dt in dtList) {
      if (dt.year != currentApptYear ||
          dt.month != currentApptMonth ||
          dt.day != currentApptDay) {
        // If the date is different, add the list of appointments to the date.
        _installTimes[
                DateTime(currentApptYear, currentApptMonth, currentApptDay)] =
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
    // Gather the last list of appointments for a date.
    _installTimes[DateTime(currentApptYear, currentApptMonth, currentApptDay)] =
        apptTimes;
    log.info('Returning the following installation times: $_installTimes');
    return _installTimes;
  }

  get mockinstallTimes async {
    DateTime dateTime = DateTime.now();
    await Future.delayed(const Duration(seconds: 2), () {
      _installTimes = {
        dateTime.add(Duration(days: 2)): ['10:30', '12:30', '13:00'],
        dateTime.add(Duration(days: 20)): ['9:15', '12:15'],
      };
    });
  }

  Future<bool> setAppt(DateTime day, String timeStr) async {
    // Remove the appointment from the list of appointments
    // Put the appointment date/time within the member's record.
    // set the appointment timestamp to now.
    //*TODO: The modification of Firebase RT should cause the backend to trigger sending a text message to the electrician as well as email and text to member services, enter task in trello????
  }
}
