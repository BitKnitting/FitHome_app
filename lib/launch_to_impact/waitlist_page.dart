import 'package:fithome_app/common_code/form_submit_button.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:fithome_app/launch_to_impact/signin/validators.dart';

class WaitListPage extends StatefulWidget with EmailAndPasswordValidators {
  @override
  _WaitListPageState createState() => _WaitListPageState();
}

class _WaitListPageState extends State<WaitListPage> {
  final Logger log = Logger('waitlist_page.dart');
  final TextEditingController _emailController = TextEditingController();

  String get _email => _emailController.text;

  List<Widget> _buildChildren() {
    bool _submitEnabled = widget.emailValidator.isValid(_email);
    return [
      SizedBox(height: 100.0),
      _buildEmailTextField(),
      SizedBox(height: 10.0),
      FormSubmitButton(
        text: 'JOIN WAITLIST',
        // The button is only active if the email is formatted correctly.
        onPressed: _submitEnabled ? _submit : null,
      ),
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
    log.info('pressed join waitlist button.');
  }

//* Build Widget
  @override
  Widget build(BuildContext context) {
    return _buildContent();
  }
}
