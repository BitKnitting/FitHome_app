import 'package:fithome_app/common_code/form_submit_button.dart';
import 'package:fithome_app/launch_to_impact/db_lookup.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:fithome_app/launch_to_impact/signin/validators.dart';

class StartTrainingPage extends StatefulWidget with EmailAndPasswordValidators {
  @override
  _StartTrainingPageState createState() => _StartTrainingPageState();
}

class _StartTrainingPageState extends State<StartTrainingPage> {
  final Logger log = Logger('start_training_page.dart');
  final TextEditingController _emailController = TextEditingController();
  String zipCodeValue = '';

  String get _email => _emailController.text;

  List<Widget> _buildChildren() {
    bool _submitEnabled = widget.emailValidator.isValid(_email);
    return [
      _buildZipCode(),
      SizedBox(height: 100.0),
      _buildEmailTextField(),
      // SizedBox(height: 10.0),
      // FormSubmitButton(
      //   text: 'Start Training',
      //   // The button is only active if the email is formatted correctly.
      //   onPressed: _submitEnabled ? _submit : null,
      // ),
    ];
  }

  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _buildChildren(),
      ),
    );
  }

  Widget _buildZipCode() {
    return Column(
      children: <Widget>[
        Text('Please choose your zip code.'),
        _zipCodeDropDown(),
      ],
    );
  }

  Widget _zipCodeDropDown() {
    return FutureBuilder(
      future: DbLookup().getZipCodes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            //               //*Todo: Handle shanpshot error.
          }
          if (snapshot.hasData) {
            List<String> zipCodes = List<String>.from(snapshot.data);
            zipCodeValue = zipCodes[0];
            return Center(
              child: Container(
                height: 50,
                child: DropdownButton<String>(
                  items: zipCodes.map((String dropDownStringItem) {
                    return DropdownMenuItem<String>(
                      value: dropDownStringItem,
                      child: Text(dropDownStringItem),
                    );
                  }).toList(),
                  onChanged: (String newValueSelected) {
                    setState(() {
                      zipCodeValue = newValueSelected;
                    });
                  },
                  value: zipCodeValue,
                ),
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
    );
  }

  Widget _buildEmailTextField() {
    bool _emailIsValid = widget.emailValidator.isValid(_email);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 16.0),
      child: TextField(
        controller: _emailController,
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        autocorrect: false,
        decoration: InputDecoration(
          hintText: widget.hintEmailText,
          icon: Icon(
            Icons.mail,
            color: Colors.grey,
          ),
          errorText: _emailIsValid ? null : widget.invalidEmailErrorText,
        ),
        onChanged: (_email) => _updateState(),
      ),
    );
    // );
  }

  // Updates the button based on validation of the email field.  If valid email, activate button.
  void _updateState() {
    setState(() {});
  }

//* Put email into Firebase wait list node.
  void _submit() {
    log.info('pressed join StartTraining button.');
  }

//* Build Widget
  @override
  Widget build(BuildContext context) {
    return _buildContent();
  }
}
