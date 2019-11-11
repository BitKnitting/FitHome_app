import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'impact_page.dart';
import 'impact_widgets.dart';

class ImpactLearningPage extends ImpactPage {
  final Logger log = Logger('impact_learning_page.dart');
  @override
  Widget buildContentSection(BuildContext context) {
    return Stack(
      children: <Widget>[
        // Putting at a height that will "max out" the flex room given by parent.
        Container(
            height: 2000,
            child: ImpactImage(image: 'assets/misc/histogram.gif')),
        _buildContentOverlay(context),
      ],
    );
  }

  @override
  Widget setTitle(BuildContext context) {
    return (Text('Learning...'));
  }

  @override
  Widget buildPlotSection(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.grey[300],
        child: new Text(
          "Plot placeholder...",
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        alignment: Alignment(0.0, 0.0),
      ),
    );
  }

  Widget _buildContentOverlay(BuildContext context) {
    return Container(color: Colors.white70);
  }
}
