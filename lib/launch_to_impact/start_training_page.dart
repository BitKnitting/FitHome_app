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

  void callback() {
    print('hello');
  }

  void onChanged() {
    setState(() {
      log.info('onChanged - setting state');
    });
  }

  Widget _buildContent() {
    //*TODO:SetState is occuring at the TextEntryWidget class.  So we're not getting a SetState.  Need a callback when the fields are validated so can turn button to blue.
    TextEntryWidget nameEntry =
        TextEntryWidget(hint: 'Name', icon: Icons.person);
    TextEntryWidget addressEntry =
        TextEntryWidget(hint: 'Address', icon: Icons.home);
    //*TODO: Next step - create account and go to setting up monitor installation appointment page.
    //*TODO: enable button when all fields have been validated.
    //*TODO: test with keyboard.  Make sure focus and keyboard "DONE" button are what you want.
    
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
                child: nameEntry,
              )),
          Flexible(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: addressEntry,
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
                // The button is only active if the fields are validated.
                //*TODO: Changing to blue when fields are validated.
                onPressed: true ? _submit : null,
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
