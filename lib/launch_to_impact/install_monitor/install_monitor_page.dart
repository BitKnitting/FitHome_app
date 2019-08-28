import 'package:fithome_app/common_code/platform_alert_dialog.dart';
import 'package:fithome_app/launch_to_impact/install_monitor/appts_%20model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

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

          _buildTableCalendar(context),
          const SizedBox(height: 8.0),

          Expanded(child: _buildEventList()),
        ],
      ),
    );
  }

  // Simple TableCalendar configuration (using Styles)
  Widget _buildTableCalendar(BuildContext context) {
    final appts = Provider.of<Appointments>(context);

    return TableCalendar(
      calendarController: _calendarController,
      events: appts.installTimes,
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
                      _eventTapped(context,event);
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
    print('$event tapped');
    String dateStr = DateFormat.MMMMEEEEd().format(_selectedDay);
    print(dateStr);
    bool scheduleAppointment = await PlatformAlertDialog(
      title: '$dateStr  $event',
      content: 'Schedule appointment?',
      defaultActionText: 'OK',
      cancelActionText: 'CANCEL',
    ).show(context);
    print(scheduleAppointment);
    if (scheduleAppointment) {
      // Update database record.
      if (await appts.setAppt(_selectedDay, event)) {}
      //*TODO: The backend will send a text/alert (hopefully?)
    }
  }
}
