import 'package:fithome_app/common_code/form_submit_button.dart';
import 'package:fithome_app/launch_to_impact/zip_code_widgets.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:fithome_app/launch_to_impact/signin/validators.dart';

import 'package:fithome_app/launch_to_impact/signin/widgets_with_validators.dart';

class StartTrainingPage extends StatefulWidget with Validators {
  @override
  _StartTrainingPageState createState() => _StartTrainingPageState();
}

class _StartTrainingPageState extends State<StartTrainingPage> {
  final Logger log = Logger('start_training_page.dart');

  Widget _buildContent() {
    //*TODO: Next step - create account and go to setting up monitor installation appointment page.
    //*TODO: enable button when all fields have been validated.
    bool _submitEnabled = false;
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Flexible(flex: 2, child: ZipCode()),
          Flexible(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: TextEntryWidget(
                  hint: 'Name',
                  icon: Icons.perm_identity,
                ),
              )),
          Flexible(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: TextEntryWidget(
                  hint: 'Address',
                  icon: Icons.home,
                ),
              )),
          Flexible(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: PhoneEntryWidget(),
              )),
          Flexible(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: EmailEntryWidget(),
              )),
          Flexible(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: TextEntryWidget(
                  hint: 'Password',
                  icon: Icons.lock,
                  obscureText: true,
                ),
              )),
          Flexible(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: TextEntryWidget(
                  hint: 'Re-enter Password',
                  icon: Icons.lock,
                  obscureText: true,
                ),
              )),
          Flexible(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FormSubmitButton(
                text: 'Start Training',
                // The button is only active if the email is formatted correctly.
                onPressed: _submitEnabled ? _submit : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

//* Create an account and go to making an appt with electrician.
  void _submit() {
    log.info('pressed join StartTraining button.');
  }

//*Build Widget
  @override
  Widget build(BuildContext context) {
    return _buildContent();
  }
}
