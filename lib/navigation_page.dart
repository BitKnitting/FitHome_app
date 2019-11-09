//************************************************************************************** */
//
//************************************************************************************** */

import 'package:fithome_app/common_code/globals.dart';
import 'package:fithome_app/contact/contact_page.dart';
import 'package:fithome_app/insight/insight_page.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'impact/impact_page.dart';
import 'launch_to_impact/install_monitor/monitors_model.dart';

class NavigationPage extends StatefulWidget {
  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  Logger log = Logger('navigation_page.dart');
  int _cIndex = 0;

  @override
  Widget build(BuildContext context) {
    final monitors = Provider.of<Monitors>(context);
    String activityState = '';
    String monitorName = '';

    _setTab(index) {
      setState(() {
        print('index: $index');
        _cIndex = index == 1 && activityState != monitorActive ? 0 : index;

        print('_cIndex: $_cIndex');
      });
    }

    return Scaffold(
      body: FutureBuilder(
        future: monitors.getInfo(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              activityState = snapshot.data['status'];
              monitorName = snapshot.data['name'];
              return _getPage(monitorName,activityState, _cIndex);
            } else {
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          } else {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        // If the requested page was the training page and the homeowner isn't actively
        // being trained, we don't allow access.
        onTap: (index) => _setTab(index),
        currentIndex: _cIndex,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.star), title: Text('Impact')),
          BottomNavigationBarItem(
            icon: new Icon(Icons.assignment_ind),
            title: new Text('Insight'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.mail),
            title: new Text('Contact Us'),
          ),
        ],
      ),
    );
  }

  Widget _getPage(String monitorName,String activityState, int cIndex) {
    // Whatever the monitor state, the impact page is available.
    if (cIndex == 0) {
      return ImpactPage(monitorName:monitorName,state: activityState);
    }
    // If the monitor isn't actively giving feedback, don't show Insight
    if (cIndex == 1) {
      if (activityState != monitorActive) {
        return ImpactPage(monitorName:monitorName, state: activityState);
      } else {
        return InsightPage();
      }
    }
    if (cIndex == 2) {
      return ContactPage();
    }
    // Shouldn't reach here.
    return Container();
  }
}
