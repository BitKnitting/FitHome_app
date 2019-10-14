import 'package:fithome_app/database/DB_model.dart';
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
  Future<String> makeMonitorName(String uid) async {
    String _monitor = await _getAvailableMonitor();

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

    /// Now that we have the full monitor name, we make a new dbref <FB Project>/{_monitorFullName}.
    /// Under the node we will have two children: 1) uid 2) readings. The readings child is "owned"
    /// by the monitor.  This is where readings are stored.  The uid associated the member with the
    /// monitor.  This is used by a back end (db) trigger.
    DBHelper().updateData(
        dbRef: DBRef.monitorRef(_monitorFullName), data: {"uid": uid});
    log.info('Created monitor node $_monitorFullName in Firebase.');

    return _monitorFullName;
  }

  //******************************************************************** */
  //* Returns true if there is a monitor within available_monitors that says
  //* It is available.
  //******************************************************************** */
  Future<bool> checkAvailability() async {
    String monitor = await _getAvailableMonitor();
    if (monitor == null) {
      return false;
    } else {
      return true;
    }
  }

  ///******************************************************************** */
  /// Once a homeowner has scheduled an appointment, the monitor can be
  /// in UI states:
  /// * not_active - The homeowner has filled out the information FitHome needs to create a member.
  /// * learn - The monitor has been installed.  It is gathering data so that the system can personalize electricity savings advice.
  /// * active - Enough learning data has been gathered to make initial personalized electricity savings recommendations.
  //******************************************************************** */
  Future<Map> getInfo(BuildContext context) async {
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
    Map _monitorInfo = await DBHelper().getData(
      dbRef: DBRef.memberMonitorRef(id),
    );
    return _monitorInfo;
  }

  //**************************************************************************
  //* Update the monitor's value to 'false' so it is no longer seen as available.
  //**************************************************************************
  void _setUnavailable(String monitor) async {
    await DBHelper().updateData(
        dbRef: DBRef.monitorsAvailableRef(), data: {monitor: false});
  }

  //******************************************************************** */
  //* Grab the list of monitors and see if any are available.  If there is one
  //* available, return the monitor name.  If not, return null.
  //******************************************************************** */
  Future<String> _getAvailableMonitor() async {
    // Go through monitors and find one that is available.  A monitor is available
    // if it's name (which is the key) is equal to 'true'.
    String _monitor;

    Map _availableMonitors;

    _availableMonitors =
        await DBHelper().getData(dbRef: DBRef.monitorsAvailableRef());
    if (_availableMonitors == null) {
      log.severe(
          '!!!Error the node available_monitors does not exist in Firebase.');
      return null;
    }

    for (String key in _availableMonitors.keys) {
      if (_availableMonitors[key] == true) {
        _monitor = key;
        break;
      }
    }
    return _monitor;
  }
}
