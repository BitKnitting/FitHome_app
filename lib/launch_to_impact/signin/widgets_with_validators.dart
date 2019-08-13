import 'package:fithome_app/launch_to_impact/signin/validators.dart';
import 'package:flutter/material.dart';
// * Text field widgets that include validations.
//********************************************************************* */
// * Email stateful Widgth
//********************************************************************* */
class EmailEntryWidget extends StatefulWidget with Validators {
  @override
  _EmailEntryWidgetState createState() => _EmailEntryWidgetState();
}

class _EmailEntryWidgetState extends State<EmailEntryWidget> {
  final TextEditingController _emailController = TextEditingController();
  String get _email => _emailController.text;
  @override
  Widget build(BuildContext context) {
    bool _emailIsValid = widget.emailValidator.isValid(_email);
    return TextField(
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
    );
  }

  // Updates the button based on validation of the email field.  If valid email, activate button.
  void _updateState() {
    setState(() {});
  }
}
//********************************************************************* */
// * Phone stateful Widgth
//********************************************************************* */
class PhoneEntryWidget extends StatefulWidget with Validators {
  @override
  _PhoneEntryWidgetState createState() => _PhoneEntryWidgetState();
}

class _PhoneEntryWidgetState extends State<PhoneEntryWidget> {
  final TextEditingController _phoneController = TextEditingController();
  bool isValid() {
    return widget.textfieldValidator.isValid(_phoneController.text);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _phoneController,
      maxLines: 1,
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      autocorrect: false,
      decoration: InputDecoration(
        hintText: widget.hintPhoneText,
        icon: Icon(
          Icons.mail,
          color: Colors.grey,
        ),
        errorText: isValid() ? null : widget.invalidPhoneErrorText,
      ),
      onChanged: (value) => _updateState(),
    );
  }

  // Updates the button based on validation of the email field.  If valid email, activate button.
  void _updateState() {
    setState(() {});
  }
}
//********************************************************************* */
// * TextField stateful Text Widgth
//********************************************************************* */
class TextEntryWidget extends StatefulWidget with Validators {
  @required
  final String hint;
  @required
  final IconData icon;
  final bool obscureText;

  TextEntryWidget({this.hint, this.icon, this.obscureText = false});

  @override
  _TextEntryWidgetState createState() => _TextEntryWidgetState();
}

class _TextEntryWidgetState extends State<TextEntryWidget> {
  final TextEditingController _textController = TextEditingController();
  bool isValid() {
    return widget.textfieldValidator.isValid(_textController.text);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: widget.obscureText,
      controller: _textController,
      maxLines: 1,
      keyboardType: TextInputType.text,
      autofocus: false,
      autocorrect: false,
      decoration: InputDecoration(
        hintText: widget.hint,
        icon: Icon(widget.icon),
        errorText: isValid()
            ? null
            : widget.hint + ' ' + widget.invalidTextfieldErrorText,
      ),
      onChanged: (value) => _updateState(),
    );
  }

  // Updates the button based on validation of the email field.  If valid email, activate button.
  void _updateState() {
    setState(() {});
  }
}
//********************************************************************* */
// * Notify when a widget's entry is valid
//********************************************************************* */
