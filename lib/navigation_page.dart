//************************************************************************************** */
//
//************************************************************************************** */

import 'package:fithome_app/common_code/globals.dart';
import 'package:fithome_app/contact/contact_page.dart';
import 'package:fithome_app/launch_to_impact/install_monitor/monitors_model.dart';
import 'package:fithome_app/training/training_page.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import 'impact/impact_page.dart';

class NavigationPage extends StatefulWidget {
  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  Logger log = Logger('navigation_page.dart');
  int _cIndex = 0;
  bool trainingPageAvailable = false;

  final List<Widget> _pageList = [ImpactPage(), InsightPage(), ContactPage()];

  @override
  Widget build(BuildContext context) {
    final monitors = Provider.of<Monitors>(context);

    _setTab(index) {
      setState(() {
        print('index: $index');
        _cIndex = index == 1 && trainingPageAvailable == false ? 0 : index;

        print('_cIndex: $_cIndex');
      });
    }

    return Scaffold(
      body: _pageList[_cIndex],
      //child: Container(color: Colors.white),
      bottomNavigationBar: FutureBuilder(
          future: monitors.getInfo(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                String _monitorState = snapshot.data['status'];
                if (_monitorState == monitorActive) {
                  trainingPageAvailable = true;
                } else {
                  trainingPageAvailable = false;
                }

                return BottomNavigationBar(
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
                );
              } else {
                return Text('');
              }
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}
