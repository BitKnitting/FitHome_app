//********************************************************************* */
//
// If the user chooses "other" for the zipcode in the startTrainingPage,
// they will be shown this page.  The purpose is to accept users that have
// been giving tickets to ok participation when thier house is not in an
// included support zipcode
//********************************************************************* */
import 'package:fithome_app/common_code/form_submit_button.dart';
import 'package:fithome_app/launch_to_impact/signin/validators.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class ZipCodeTicketPage extends StatefulWidget with Validators {
  @override
  _ZipCodeTicketState createState() => _ZipCodeTicketState();
}

enum TicketChoice { have, dont_have }
TicketChoice ticketChoice = TicketChoice.have;

class _ZipCodeTicketState extends State<ZipCodeTicketPage> {
  final Logger log = Logger('zipcode_ticket.dart');
  final TextEditingController _ticketController = TextEditingController();
  final TextEditingController _zipcodeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final FocusNode _ticketFocusNode = FocusNode();
  final FocusNode _zipcodeFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();

  String get _ticket => _ticketController.text;
  String get _zipcode => _zipcodeController.text;
  String get _email => _emailController.text;
  String get _phone => _phoneController.text;
  //********************************************************************** */
  //* Called when onEditingComplete callback = typically goes to next button.
  //********************************************************************** */

  void _ticketEditingComplete() {
    FocusScope.of(context).requestFocus(_zipcodeFocusNode);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Other Zipcodes'),
          elevation: 5.0,
        ),
        //resizeToAvoidBottomInset: true,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(30, 30.0, 30, 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                    'We can only provide quality support within the listed zipcodes.  Occassionaly, we issue exception tickets.',
                    style: TextStyle(fontSize: 18)),
                _ticketChoices(),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //********************************************************************** */
  //* Handle submit button pressed
  //********************************************************************** */
  void _submit() {
    log.info('OK button pressed.');
  }
  //********************************************************************** */
  //* Build submit button
  //********************************************************************** */

  FormSubmitButton _buildSubmitButton() {
    bool _submitEnabled = false;
    if (ticketChoice == TicketChoice.have) {
      _submitEnabled = widget.ticketValidator.isValid(_ticket) &&
          widget.zipcodeValidator.isValid(_zipcode);
    } else {
      _submitEnabled = widget.zipcodeValidator.isValid(_zipcode) ||
          widget.emailValidator.isValid(_email);
    }
  
    return FormSubmitButton(
      text: 'OK',
      //*TODO: Handle ticket request
      // I find it "weird" that onPressed controls active/inactive...
      onPressed: _submitEnabled ? _submit : null,
    );
  }

  //********************************************************************** */
  //* Build have a ticket / want a ticket part of page.
  //********************************************************************** */

  Widget _ticketChoices() {
    return Column(
      children: <Widget>[
        ListTile(
          title: const Text('I have an exception ticket'),
          leading: Radio(
            value: TicketChoice.have,
            groupValue: ticketChoice,
            onChanged: (TicketChoice value) {
              setState(() {
                ticketChoice = value;
              });
            },
          ),
        ),
        _buildTicketTextField(),
        _buildZipcodeTextField(),
        ListTile(
          title: const Text("I'd like an exception ticket"),
          leading: Radio(
            value: TicketChoice.dont_have,
            groupValue: ticketChoice,
            onChanged: (value) => _updateTicketChoice(value),
          ),
        ),
        _buildEmailTextField(),
        Text('or', style: TextStyle(fontSize: 18)),
        _buildPhoneTextField(),
      ],
    );
  }

  //********************************************************************** */
  //* Build ticket
  //********************************************************************** */
  TextField _buildTicketTextField() {
    bool showErrorText = !widget.ticketValidator.isValid(_ticket);
    return TextField(
      controller: _ticketController,
      focusNode: _ticketFocusNode,
      decoration: InputDecoration(
        icon: Icon(Icons.confirmation_number, color: Colors.grey),
        labelText: 'Ticket Number',
        errorText: showErrorText ? widget.invalidTicketErrorText : null,
        enabled: ticketChoice == TicketChoice.have,
      ),
      autocorrect: false,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      onChanged: (name) => _updateState(),
      onEditingComplete: _ticketEditingComplete,
    );
  }

  //********************************************************************** */
  //* Build zipcode
  //********************************************************************** */
  TextField _buildZipcodeTextField() {
    bool showErrorText = !widget.zipcodeValidator.isValid(_zipcode);
    return TextField(
      controller: _zipcodeController,
      focusNode: _zipcodeFocusNode,
      decoration: InputDecoration(
        icon: Icon(Icons.home, color: Colors.grey),
        labelText: 'Zipcode',
        errorText: showErrorText ? widget.invalidZipcodeText : null,
        enabled: ticketChoice == TicketChoice.have,
      ),
      autocorrect: false,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      onChanged: (name) => _updateState(),
      //*TODO: Entry for authorizing ticket finished.  Look in database, approve = go back to Start training.
      //onEditingComplete: _nameEditingComplete,
    );
  }
  //********************************************************************** */
  //* Build email
  //********************************************************************** */

  TextField _buildEmailTextField() {
    bool showErrorText = !widget.emailValidator.isValid(_email);
    return TextField(
      controller: _emailController,
      focusNode: _emailFocusNode,
      decoration: InputDecoration(
        icon: Icon(Icons.mail, color: Colors.grey),
        labelText: widget.hintEmailText,
        errorText: showErrorText ? widget.invalidEmailErrorText : null,
        enabled: ticketChoice == TicketChoice.dont_have,
      ),
      autocorrect: false,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onChanged: (email) => _updateState(),
      // onEditingComplete: _emailEditingComplete,
    );
  }

  //********************************************************************** */
  //* Build phone
  //********************************************************************** */
  TextField _buildPhoneTextField() {
    bool showErrorText = !widget.phoneValidator.isValid(_phone);
    return TextField(
      controller: _phoneController,
      focusNode: _phoneFocusNode,
      decoration: InputDecoration(
        icon: Icon(Icons.phone, color: Colors.grey),
        labelText: widget.hintPhoneText,
        errorText: showErrorText ? widget.invalidPhoneErrorText : null,
        enabled: ticketChoice == TicketChoice.dont_have,
      ),
      autocorrect: false,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      onChanged: (phone) => _updateState(),
      //onEditingComplete: _phoneEditingComplete,
    );
  }

  _updateState() {
    setState(() {});
  }

  _updateTicketChoice(TicketChoice value) {
    setState(() {
      ticketChoice = value;
    });
  }
}
