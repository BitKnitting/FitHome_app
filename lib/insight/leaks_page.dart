import 'package:fithome_app/common_code/custom_raised_button.dart';
import 'package:fithome_app/common_code/image_feed_utils.dart';
import 'package:fithome_app/impact/impact_content.dart';
import 'package:fithome_app/impact/impact_stream.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class LeaksPage extends StatefulWidget {
  static const String routeName = "/leaks";

  @override
  _LeaksPageState createState() => _LeaksPageState();
}

class _LeaksPageState extends State<LeaksPage> {
  Logger log = Logger('leaks_page.dart');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          title: new Text("Electricity Leaks"),
          actions: <Widget>[
            new IconButton(
                icon: new Icon(Icons.info), iconSize: 40, onPressed: _info),
          ],
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          textTheme: TextTheme(
              title: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
          )),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(0, 30.0, 0, 0),
          child: Column(
            children: <Widget>[
              Flexible(flex: 1, child: _percentOfTotalElectricity(27)),
              Flexible(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      _leakWatts(161),
                    ],
                  ),
                ),
              ),
              Flexible(
                flex: 5,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    StreamBuilder(
                        stream: ImpactImages().stream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.active) {
                            if (snapshot.hasData) {
                              return Stack(
                                children: <Widget>[
                                  Image.asset(
                                    snapshot.data,
                                    fit: BoxFit.fill,
                                    width:
                                        MediaQuery.of(context).size.width * .8,
                                  ),
                                  _impactCard(snapshot.data),
                                ],
                              );
                              // return Container(
                              //   child: Image.asset(snapshot.data),
                              // );
                              // buildImageLayer(snapshot.data);
                            } else if (snapshot.hasError) {
                              log.severe('!!! ERROR: ${snapshot.error}');
                            }
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                        })
                  ],
                ),
              ),

              //  Find Leaks Button
              Flexible(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
                        child: CustomRaisedButton(
                          height: 50.0,
                          borderRadius: 4.0,
                          color: Colors.indigo,
                          child: Text(
                            'Find Leaks',
                            style:
                                TextStyle(color: Colors.white, fontSize: 20.0),
                          ),
                          onPressed: _submit,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  void _submit() {
    print('submit pressed');
  }

  _info() {
    print('info pressed');
  }

  // ************************************************************************************************
  // UI to show the amount of watts that leak are waisted all the time.
  // ************************************************************************************************
  Widget _leakWatts(int nWatts) {
    // *TODO: Calculate kWh from nWatts
    int kWh = 1400;
    return Column(
      children: <Widget>[
        Container(
          width: 81,
          height: 76,
          margin: EdgeInsets.only(left: 20),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 0,
                top: 0,
                child: Image.asset('assets/insightsImages/drippingFaucet.png',
                    width: 67.0, height: 71.0),
              ),
              Positioned(
                left: 25,
                top: 50,
                child: Text(
                  nWatts.toString() + "w",
                  style: _commonTextStyle(),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Text(
          kWh.toString() + ' kWh/year',
          style: _commonTextStyle(),
        ),
      ],
    );
  }

  // ************************************************************************************************
  // Text Style decided to use for this page.
  // ************************************************************************************************
  _commonTextStyle() {
    return TextStyle(
      // color: Color.fromARGB(255, 7, 1, 1),
      fontSize: 20,
      letterSpacing: 0.357,
      fontFamily: "Roboto",
      fontWeight: FontWeight.w500,
    );
  }

  Widget _percentOfTotalElectricity(int percentOfTotal) {
    return Text(
      percentOfTotal.toString() + '% of Total Electricity',
      style: _commonTextStyle(),
    );
  }

  Widget _impactCard(imagePath) {
    return Positioned(
      bottom: 10,
      left: 5,
      right: 5,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Opacity(
              opacity: .75,
              child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5)))),
          Column(
            children: <Widget>[
              Text(
                'Yearly impact',
                style: _commonTextStyle(),
              ),
              impactEquivalent(context, 4052, imagePath),
            ],
          )
        ],
      ),
    );
  }
}
