import 'package:fithome_app/common_code/platform_alert_dialog.dart';

import 'package:fithome_app/launch_to_impact/install_monitor/appts_model.dart';
import 'package:fithome_app/launch_to_impact/waitlist_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import '../../navigation_page.dart';
import '../../table_calendar.dart';

class InstallMonitorPage extends StatefulWidget {
  @override
  _InstallMonitorPageState createState() => _InstallMonitorPageState();
}

class _InstallMonitorPageState extends State<InstallMonitorPage>
    with TickerProviderStateMixin {
  Logger log = Logger('install_monitor_page.dart');

  List _selectedEvents = List();

  CalendarController _calendarController = CalendarController();

  Map<DateTime, List> _events = Map<DateTime, List>();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();

    // _events = {
    //   _selectedDay.subtract(Duration(days: 30)): [
    //     'Event A0',
    //     'Event B0',
    //     'Event C0'
    //   ],
    //   _selectedDay.subtract(Duration(days: 27)): ['Event A1'],
    //   _selectedDay.subtract(Duration(days: 20)): [
    //     'Event A2',
    //     'Event B2',
    //     'Event C2',
    //     'Event D2'
    //   ],
    //   _selectedDay.subtract(Duration(days: 16)): ['Event A3', 'Event B3'],
    //   _selectedDay.subtract(Duration(days: 10)): [
    //     'Event A4',
    //     'Event B4',
    //     'Event C4'
    //   ],
    //   _selectedDay.subtract(Duration(days: 4)): [
    //     'Event A5',
    //     'Event B5',
    //     'Event C5'
    //   ],
    //   _selectedDay.subtract(Duration(days: 2)): ['Event A6', 'Event B6'],
    //   _selectedDay: ['Event A7', 'Event B7', 'Event C7', 'Event D7'],
    //   _selectedDay.add(Duration(days: 1)): [
    //     'Event A8',
    //     'Event B8',
    //     'Event C8',
    //     'Event D8'
    //   ],
    //   _selectedDay.add(Duration(days: 3)):
    //       Set.from(['Event A9', 'Event A9', 'Event B9']).toList(),
    //   _selectedDay.add(Duration(days: 7)): [
    //     'Event A10',
    //     'Event B10',
    //     'Event C10'
    //   ],
    //   _selectedDay.add(Duration(days: 11)): ['Event A11', 'Event B11'],
    //   _selectedDay.add(Duration(days: 17)): [
    //     'Event A12',
    //     'Event B12',
    //     'Event C12',
    //     'Event D12'
    //   ],
    //   _selectedDay.add(Duration(days: 22)): ['Event A13', 'Event B13'],
    //   _selectedDay.add(Duration(days: 26)): [
    //     'Event A14',
    //     'Event B14',
    //     'Event C14'
    //   ],
    // };
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime day, List events) {
    log.info('CALLBACK: _onDaySelected.  Day: $day  Events: $events');
    setState(() {
      _selectedDay = day;
      _selectedEvents = events;
    });
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    log.info('CALLBACK: _onVisibleDaysChanged');
    setState(() {
      // Reset events so the old events aren't shwoing when change the month.
      _selectedEvents = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule an Appointment'),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(child: _buildTableCalendar(context)),
          const SizedBox(height: 8.0),
          Expanded(child: _buildEventList()),
        ],
      ),
    );
  }

  // Simple TableCalendar configuration (using Styles)
  // Widget _buildTableCalendar(BuildContext context) {
  //   final appts = Provider.of<Appointments>(context);
  //   return FutureBuilder(
  //     // The Table Calendar gets rebuilt many times.  However, the first time we need the install times.
  //     future: appts.getCalendarDateTimes(context),
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.done) {
  //         if (snapshot.hasData) {
  //           return TableCalendar(
  //             calendarController: _calendarController,
  //             events: snapshot.data,
  //             startingDayOfWeek: StartingDayOfWeek.sunday,
  //             calendarStyle: CalendarStyle(
  //               selectedColor: Colors.deepOrange[400],
  //               todayColor: Colors.deepOrange[200],
  //               markersColor: Colors.brown[700],
  //               outsideDaysVisible: false,
  //             ),
  //             headerStyle: HeaderStyle(
  //               formatButtonVisible: false,
  //             ),
  //             onDaySelected: _onDaySelected,
  //             onVisibleDaysChanged: _onVisibleDaysChanged,
  //           );
  //         } else {
  //           //*TODO: Better handling when the available_appointments node not in database.
  //           log.severe(
  //               '!!! Error - there are no available monitor installation appointments.');
  //           return WaitListPage();
  //         }
  //       } else {
  //         return Scaffold(
  //           body: Center(
  //             child: CircularProgressIndicator(),
  //           ),
  //         );
  //       }
  //     },
  //   );
  // }
  Widget _buildTableCalendar(BuildContext context) {
    // final appts = Provider.of<Appointments>(context);
    // appts.getCalendarDateTimes(context).then((availableAppts) {
    //   _events = availableAppts;
    //   print('$_events');
    //   print('hello!!!');
    // });
    //** */
    // I get the events from the db.  So FutureBuilder makes sense.  Particularly because
    // the events is set once.  However, if Futurebuilder keeps getting relentlessly called,
    // calendar features stop working, like the selected Color and going to prev/next months.
    // My "kludge" is to figure out if the events list is empty and only use future builder at
    // that point.
    if (_events.isEmpty) {
      return FutureBuilder(
          future: _getEvents(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                return TableCalendar(
                  calendarController: _calendarController,
                  events: snapshot.data,
                  startingDayOfWeek: StartingDayOfWeek.sunday,
                  calendarStyle: CalendarStyle(
                    selectedColor: Colors.deepOrange[400],
                    todayColor: Colors.deepOrange[200],
                    markersColor: Colors.brown[700],
                    outsideDaysVisible: false,
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                  ),
                  onDaySelected: _onDaySelected,
                  onVisibleDaysChanged: _onVisibleDaysChanged,
                );
              }
            }
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          });
    }
    //* Events have been populated.  Don't use FutureBuilder.
    return TableCalendar(
      calendarController: _calendarController,
      events: _events,
      startingDayOfWeek: StartingDayOfWeek.sunday,
      calendarStyle: CalendarStyle(
        selectedColor: Colors.deepOrange[400],
        todayColor: Colors.deepOrange[200],
        markersColor: Colors.brown[700],
        outsideDaysVisible: false,
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
      ),
      onDaySelected: _onDaySelected,
      onVisibleDaysChanged: _onVisibleDaysChanged,
    );
  }

  Widget _buildEventList() {
    return ListView(
      children: _selectedEvents
          .map((event) => Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 0.8),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                margin:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                    title: Text(event.toString()),
                    onTap: () {
                      _eventTapped(context, event);
                    }),
              ))
          .toList(),
    );
  }

  //********************************************************************** */
  //* User has tapped on one of the available appointments.
  //********************************************************************** */
  void _eventTapped(BuildContext context, dynamic event) async {
    final appts = Provider.of<Appointments>(context);

    String dateStr = DateFormat.MMMMEEEEd().format(_selectedDay);
    bool scheduleAppointment = await PlatformAlertDialog(
      title: '$dateStr  $event',
      content: 'Schedule appointment?',
      defaultActionText: 'OK',
      cancelActionText: 'CANCEL',
    ).show(context);

    if (scheduleAppointment) {
      log.info(
          'Member chose to schedule appointment'); //   // Update database record.
      if (await appts.setAppt(context, _selectedDay, event)) {
        log.info(
            'appointment has been scheduled for day: $_selectedDay and time: $event');
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            fullscreenDialog: true, builder: (context) => NavigationPage()));
      } else {
        //*TODO: Error trying to set up monitor install appointment... need UI and error handling to member services.
        log.severe(
            '!!! Could not set appointment for day: $_selectedDay and time: $event');
      }
    }
  }

  Future<Map<DateTime, List>> _getEvents(BuildContext context) async {
    final appts = Provider.of<Appointments>(context);
    _events = await appts.getCalendarDateTimes(context);
    //* DEBUG/TEST
    // final _selectedDay = DateTime.now();
    // await Future.delayed(const Duration(seconds: 1), () {
    //   _events = {
    //     _selectedDay.subtract(Duration(days: 30)): [
    //       'Event A0',
    //       'Event B0',
    //       'Event C0'
    //     ],
    //     _selectedDay.subtract(Duration(days: 27)): ['Event A1'],
    //     _selectedDay.subtract(Duration(days: 20)): [
    //       'Event A2',
    //       'Event B2',
    //       'Event C2',
    //       'Event D2'
    //     ],
    //     _selectedDay.subtract(Duration(days: 16)): ['Event A3', 'Event B3'],
    //     _selectedDay.subtract(Duration(days: 10)): [
    //       'Event A4',
    //       'Event B4',
    //       'Event C4'
    //     ],
    //     _selectedDay.subtract(Duration(days: 4)): [
    //       'Event A5',
    //       'Event B5',
    //       'Event C5'
    //     ],
    //     _selectedDay.subtract(Duration(days: 2)): ['Event A6', 'Event B6'],
    //     _selectedDay: ['Event A7', 'Event B7', 'Event C7', 'Event D7'],
    //     _selectedDay.add(Duration(days: 1)): [
    //       'Event A8',
    //       'Event B8',
    //       'Event C8',
    //       'Event D8'
    //     ],
    //     _selectedDay.add(Duration(days: 3)):
    //         Set.from(['Event A9', 'Event A9', 'Event B9']).toList(),
    //     _selectedDay.add(Duration(days: 7)): [
    //       'Event A10',
    //       'Event B10',
    //       'Event C10'
    //     ],
    //     _selectedDay.add(Duration(days: 11)): ['Event A11', 'Event B11'],
    //     _selectedDay.add(Duration(days: 17)): [
    //       'Event A12',
    //       'Event B12',
    //       'Event C12',
    //       'Event D12'
    //     ],
    //     _selectedDay.add(Duration(days: 22)): ['Event A13', 'Event B13'],
    //     _selectedDay.add(Duration(days: 26)): [
    //       'Event A14',
    //       'Event B14',
    //       'Event C14'
    //     ],
    //   };
    // });

    return _events;
  }
}
