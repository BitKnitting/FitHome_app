//?TBD:   textInputAction: TextInputAction.next... does not work on phone keyboard. The implication is
//?the user can't use the keyboard next button to get to the next Textfield. For now not using phone keyboard.
//*TODO: All the goo around submitting.
//********************************************************************** */
//* start_training.dart
//* UI for the Start Training step.
//* Copyright Happyday, 2019.
//********************************************************************** */

import 'package:after_layout/after_layout.dart';
import 'package:fithome_app/common_code/form_submit_button.dart';
import 'package:fithome_app/launch_to_impact/install_monitor_page.dart';
import 'package:fithome_app/launch_to_impact/zip_code_widgets.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:fithome_app/launch_to_impact/signin/validators.dart';

class StartTrainingPage extends StatefulWidget with Validators {
  @override
  _StartTrainingPageState createState() => _StartTrainingPageState();
}

class _StartTrainingPageState extends State<StartTrainingPage>
    with AfterLayoutMixin {
  final Logger log = Logger('start_training_page.dart');
  //  expand is used to determine if the zipcode text should expand.
  // afterFirstLayout gets called after the widgets have been built.
  // It is part of the AfterLayoutMixin.
  bool expand = false;
  @override
  void afterFirstLayout(BuildContext context) {
    setState(() {
      expand = !expand;
    });
  }

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _reEnterPasswordController =
      TextEditingController();

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _addressFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _reEnterPasswordFocusNode = FocusNode();

  String get _email => _emailController.text;
  String get _name => _nameController.text;
  String get _phone => _phoneController.text;
  String get _address => _addressController.text;
  String get _password => _passwordController.text;
  String get _reEnterPassword => _reEnterPasswordController.text;
  //********************************************************************** */
  //* Called when onEditingComplete callback = typically goes to next button.
  //********************************************************************** */

  void _nameEditingComplete() {
    FocusScope.of(context).requestFocus(_emailFocusNode);
  }

  void _emailEditingComplete() {
    FocusScope.of(context).requestFocus(_phoneFocusNode);
  }

  void _phoneEditingComplete() {
    FocusScope.of(context).requestFocus(_addressFocusNode);
  }

  void _addressEditingComplete() {
    FocusScope.of(context).requestFocus(_passwordFocusNode);
  }

  void _passwordEditingComplete() {
    FocusScope.of(context).requestFocus(_reEnterPasswordFocusNode);
  }

  void _reEnterPasswordEditingComplete() {
    FocusScope.of(context).requestFocus(_reEnterPasswordFocusNode);
  }

  //********************************************************************** */
  //* Build the textfields that need to be filled in.
  //********************************************************************** */
  Widget _buildStartTrainingForm() {
    bool isZipCodeChosen = false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _ZipCodeText(isZipCodeChosen: isZipCodeChosen, expand: expand),
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
          child: ZipCode(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
          child: _buildNameTextField(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
          child: _buildEmailTextField(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
          child: _buildPhoneTextField(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
          child: _buildAddressTextField(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
          child: _buildPasswordTextField(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
          child: _buildReEnterPasswordTextField(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
          child: _buildSubmitButton(),
        ),
      ],
    );
  }

  //********************************************************************** */
  //* All the fields are valid.  Now we take the info on the form to the
  //* next step.
  //********************************************************************** */
  void _submit() {
    log.info('pressed join StartTraining button.');
    // Create an account.
    // Push the InstallMonitorPage
    // fullscreenDialog: true is for iOS to load the page from the bottom.
    Navigator.of(context).push(MaterialPageRoute(
        fullscreenDialog: true, builder: (context) => InstallMonitorPage()));
  }

  //********************************************************************** */
  //* Build name
  //********************************************************************** */
  TextField _buildNameTextField() {
    bool showErrorText = !widget.textfieldValidator.isValid(_name);
    return TextField(
      controller: _nameController,
      focusNode: _nameFocusNode,
      decoration: InputDecoration(
        icon: Icon(Icons.person, color: Colors.grey),
        labelText: 'Name',
        errorText: showErrorText ? widget.invalidTextfieldErrorText : null,
      ),
      autocorrect: false,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      onChanged: (name) => _updateState(),
      onEditingComplete: _nameEditingComplete,
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
      ),
      autocorrect: false,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onChanged: (email) => _updateState(),
      onEditingComplete: _emailEditingComplete,
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
      ),
      autocorrect: false,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      onChanged: (phone) => _updateState(),
      onEditingComplete: _phoneEditingComplete,
    );
  }

  //********************************************************************** */
  //* Build address
  //********************************************************************** */
  TextField _buildAddressTextField() {
    bool showErrorText = !widget.textfieldValidator.isValid(_address);
    return TextField(
      controller: _addressController,
      focusNode: _addressFocusNode,
      decoration: InputDecoration(
        icon: Icon(Icons.home, color: Colors.grey),
        labelText: 'Address',
        errorText: showErrorText ? widget.invalidTextfieldErrorText : null,
      ),
      autocorrect: false,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      onChanged: (address) => _updateState(),
      onEditingComplete: _addressEditingComplete,
    );
  }

  //********************************************************************** */
  //* Build password
  //********************************************************************** */
  TextField _buildPasswordTextField() {
    bool showErrorText = !widget.textfieldValidator.isValid(_password);
    return TextField(
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      decoration: InputDecoration(
        icon: Icon(Icons.lock, color: Colors.grey),
        labelText: 'Password',
        errorText: showErrorText ? widget.invalidTextfieldErrorText : null,
        //    enabled: _isLoading == false,
      ),
      obscureText: true,
      textInputAction: TextInputAction.next,
      onChanged: (password) => _updateState(),
      onEditingComplete: _passwordEditingComplete,
    );
  }

  //********************************************************************** */
  //* Build re-enter password
  //********************************************************************** */
  TextField _buildReEnterPasswordTextField() {
    String value = _password + ',' + _reEnterPassword;
    bool showErrorText = !widget.reEnterPasswordValidator.isValid(value);
    return TextField(
      controller: _reEnterPasswordController,
      focusNode: _reEnterPasswordFocusNode,
      decoration: InputDecoration(
        icon: Icon(Icons.lock, color: Colors.grey),
        labelText: 'Re-enter Password',
        errorText: showErrorText ? widget.invalidReEnterPasswordText : null,
        //    enabled: _isLoading == false,
      ),
      obscureText: true,
      textInputAction: TextInputAction.done,
      onChanged: (reEnterPassword) => _updateState(),
      onEditingComplete: _reEnterPasswordEditingComplete,
    );
  }

  //********************************************************************** */
  //* Build submit button
  //********************************************************************** */
  FormSubmitButton _buildSubmitButton() {
    String valueForReEnterPasswordValidator =
        _password + ',' + _reEnterPassword;
    bool _submitEnabled = widget.emailValidator.isValid(_email);
    // &&
    //     widget.textfieldValidator.isValid(_name) &&
    //     widget.phoneValidator.isValid(_phone) &&
    //     widget.textfieldValidator.isValid(_address) &&
    //     widget.textfieldValidator.isValid(_password) &&
    //     widget.reEnterPasswordValidator
    //         .isValid(valueForReEnterPasswordValidator);

    return FormSubmitButton(
      text: 'Start Training',
      // The button is only active if the email is formatted correctly.
      onPressed: _submitEnabled ? _submit : null,
    );
  }

  //********************************************************************** */
  //* Build widgets
  //********************************************************************** */
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
          child: _buildStartTrainingForm(),
        ),
      ],
    );
  }

  //********************************************************************** */
  //* Update State
  //********************************************************************** */
  void _updateState() {
    setState(() {});
  }
}

class _ZipCodeText extends StatelessWidget {
  const _ZipCodeText({
    Key key,
    @required this.isZipCodeChosen,
    @required this.expand,
  }) : super(key: key);

  final bool isZipCodeChosen;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: Visibility(
        visible: isZipCodeChosen ? false : true,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(seconds: 1),
          style: expand
              ? TextStyle(
                  fontSize: 30, color: Colors.red, fontWeight: FontWeight.bold)
              : TextStyle(
                  fontSize: 10,
                  color: Colors.black,
                  fontWeight: FontWeight.normal),
          child: Text(
            'Choose your Zip Code',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
