//************************************************************************************** */
//
//************************************************************************************** */

import 'package:fithome_app/common_code/globals.dart';
import 'package:fithome_app/contact/contact_page.dart';
import 'package:fithome_app/insight/insight_page.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'impact/impact_active_page.dart';
import 'impact/impact_learning_page.dart';
import 'impact/impact_not_active_page.dart';
import 'impact/impact_page.dart';
import 'launch_to_impact/install_monitor/monitors_model.dart';

class NavigationPage extends StatefulWidget {
  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  Logger log = Logger('navigation_page.dart');
  static const _ImpactPage = 0;
  static const _InsightPage = 1;
  static const _ContactPage = 2;
  int _cIndex = _ImpactPage;

  @override
  Widget build(BuildContext context) {
    final monitors = Provider.of<Monitors>(context);
    String activityState = '';
    String monitorName = '';

    _setTab(index) {
      setState(() {
        print('index: $index');
        // Only when the monitor is active will the InsightPage be shown.
        _cIndex = index == _InsightPage && activityState != monitorActive
            ? _ImpactPage
            : index;

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
              return _getPage(monitorName, activityState, _cIndex);
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

  //****************************************************************************** */
  /// cIndex lets us know what Bottom Navigation icon was tapped.
  /// Insights are only relevant when the monitor is in the active state.  If the
  /// homeowner clicks on Insights and the monitor is not in the active state, the
  /// homeowner is shown an Impact screen for either learning or not active.
  //****************************************************************************** */
  Widget _getPage(String monitorName, String activityState, int cIndex) {
    // Whatever the monitor state, the impact page is available.
    if (cIndex == _ImpactPage) {
      //return ImpactPage(state: activityState);
      return ImpactActivePage(monitorName:monitorName);
    }
    // If the monitor isn't actively giving feedback, don't show Insight
    if (cIndex == _InsightPage) {
      if (activityState != monitorActive) {
        //return ImpactPage(state: activityState);
        return ImpactNotActivePage();
      } else {
        return InsightPage();
      }
    }
    if (cIndex == _ContactPage) {
      return ContactPage();
    }
    // Shouldn't reach here.
    return Container();
  }
}
