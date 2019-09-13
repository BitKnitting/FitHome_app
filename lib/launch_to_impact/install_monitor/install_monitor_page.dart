import 'package:fithome_app/common_code/platform_alert_dialog.dart';

import 'package:fithome_app/launch_to_impact/install_monitor/appts_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../navigation_page.dart';

class InstallMonitorPage extends StatefulWidget {
  @override
  _InstallMonitorPageState createState() => _InstallMonitorPageState();
}

class _InstallMonitorPageState extends State<InstallMonitorPage>
    with TickerProviderStateMixin {
  Logger log = Logger('install_monitor_page.dart');

  List _selectedEvents = List();

  CalendarController _calendarController = CalendarController();
  DateTime _selectedDay = DateTime.now();

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
  Widget _buildTableCalendar(BuildContext context) {
    final appts = Provider.of<Appointments>(context);
    return FutureBuilder(
      // The Table Calendar gets rebuilt many times.  However, the first time we need the install times.
      future: appts.getCalendarDateTimes(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return TableCalendar(
              calendarController: _calendarController,
              events: snapshot.data,
              startingDayOfWeek: StartingDayOfWeek.sunday,
              calendarStyle: CalendarStyle(
                selectedColor: Colors.deepOrange[400],
                todayColor: Colors.purple[200],
                markersColor: Colors.brown[700],
                outsideDaysVisible: false,
              ),
              headerStyle: HeaderStyle(
                // We'll show the month and chevron, but not the button.
                formatButtonVisible: false,
              ),
              onDaySelected: _onDaySelected,
              onVisibleDaysChanged: _onVisibleDaysChanged,
            );
          } else {
            log.severe(
                '!!! Error - there are no available monitor installation appointments.  However checks were made previously.');
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

  // return TableCalendar(
  //   calendarController: _calendarController,
  //   events: appts.installTimes,
  //   startingDayOfWeek: StartingDayOfWeek.sunday,
  //   calendarStyle: CalendarStyle(
  //     selectedColor: Colors.deepOrange[400],
  //     todayColor: Colors.purple[200],
  //     markersColor: Colors.brown[700],
  //     outsideDaysVisible: false,
  //   ),
  //   headerStyle: HeaderStyle(
  //     // We'll show the month and chevron, but not the button.
  //     formatButtonVisible: false,
  //   ),
  //   onDaySelected: _onDaySelected,
  //   onVisibleDaysChanged: _onVisibleDaysChanged,
  // );

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
    print(
        '_selectedDay type: ${_selectedDay.runtimeType}  value: $_selectedDay');
    print('Event type: ${event.runtimeType}  value: $event');
    final appts = Provider.of<Appointments>(context);
    print('$event tapped');
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
        //*TODO: pop the installMonitorPage
        //*TODO: push the page showing waiting for monitor to be installed.
      } else {
        //*TODO: Error trying to set up monitor install appointment... need UI and error handling to member services.
        log.severe(
            '!!! Could not set appointment for day: $_selectedDay and time: $event');
      }
    }
  }
}
