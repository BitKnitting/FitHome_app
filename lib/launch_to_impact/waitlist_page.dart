import 'package:fithome_app/common_code/form_submit_button.dart';
import 'package:fithome_app/launch_to_impact/signin/widgets_with_validators.dart';
import 'package:fithome_app/launch_to_impact/zip_code_widgets.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:fithome_app/launch_to_impact/signin/validators.dart';

class WaitListPage extends StatefulWidget with Validators {
  @override
  _WaitListPageState createState() => _WaitListPageState();
}

class _WaitListPageState extends State<WaitListPage> {
  final Logger log = Logger('waitlist_page.dart');

  Widget _buildContent() {
    //*TODO: Do next steps after button is pressed (e.g.: add email to waitlist...)
  
    //*TODO: Get focus right with keyboard....test with keyboard.  Make sure focus and keyboard "DONE" button are what you want.
    bool _submitEnabled = false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Flexible(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: ZipCode(),
            )),
        Flexible(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: EmailEntryWidget(),
            )),
        Flexible(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FormSubmitButton(
              text: 'Join Waitlist',
              // The button is only active if the email is formatted correctly.
              onPressed: _submitEnabled ? _submit : null,
            ),
          ),
        ),
      ],
    );
  }

//* Put email into Firebase wait list node.
  void _submit() {
    log.info('pressed join JOIN WAITLIST button.');
  }

//* Build Widget
  @override
  Widget build(BuildContext context) {
    return _buildContent();
  }
}
