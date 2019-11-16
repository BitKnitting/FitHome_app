//************************************************************************* */
// While the content of the impact page is different depending on the monitor's
// state, the layout is the same.

import 'package:flutter/material.dart';

abstract class ImpactPage extends StatelessWidget {
  Widget buildContentSection(BuildContext context);
  Widget buildActionSection(BuildContext context);
  Widget setTitle(BuildContext context);
  // Widget buildPlotSection(BuildContext context);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //  Set the title based on the state of the monitor.
      appBar: AppBar(
        title: setTitle(context),
      ),
      body: Column(
        children: [
          Flexible(child: buildContentSection(context), flex: 2),
          Flexible(child: buildActionSection(context), flex: 1),
        ],
      ),
    );
  }
}
