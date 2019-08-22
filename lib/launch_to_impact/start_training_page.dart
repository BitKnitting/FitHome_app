//?TBD:   textInputAction: TextInputAction.next... does not work on phone keyboard. The implication is
//?the user can't use the keyboard next button to get to the next Textfield. For now not using phone keyboard.
//*TODO: Merge back with main.
//********************************************************************** */
//* start_training.dart
//* UI for the Start Training step.
//* Copyright Happyday, 2019.
//********************************************************************** */

import 'package:after_layout/after_layout.dart';
import 'package:fithome_app/common_code/form_submit_button.dart';
import 'package:fithome_app/launch_to_impact/zip_code_widgets.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:fithome_app/launch_to_impact/signin/validators.dart';
import 'package:provider/provider.dart';

import 'signin/auth_service.dart';

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
  ZipCode zipPullDown = ZipCode();
  bool isValidZip = false;
  bool expandFillInText = false;

  @override
  void initState() {
    super.initState();
    zipPullDown.zipCodeString.addListener(_zipCodeStringListener);
  }

  @override
  void afterFirstLayout(BuildContext context) {
    setState(() {
      expand = true;
    });
  }

  // One of the values within the zipcode pulldown was chosen
  void _zipCodeStringListener() {
    log.info('user chose zip code: ***>${zipPullDown.zipCodeString.value}<***');
    if (widget.zipcodeValidator.isValid(zipPullDown.zipCodeString.value)) {
      expand = false;
      isValidZip = true;
      _checkExpandText();
    } else {
      expand = true;
      isValidZip = false;
      _checkExpandText();
    }
    setState(() {});
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
  //* Update State
  //********************************************************************** */
  void _updateState() {
    setState(() {
      _checkExpandText();
    });
  }
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
    _submit();
  }

  //********************************************************************** */
  //* Build the textfields that need to be filled in.
  //********************************************************************** */
  Widget _buildStartTrainingForm() {
    log.info('buildStartTrainingForm');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Don't show if user has picked a valid zipcode from the pulldown.
        // Show expanded text if this is the first time the page is displayed.
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
          child: _ZipCodeText(expand: expand),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
          child: zipPullDown,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
          child: _FillFormText(expand: expandFillInText),
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
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
          child: _buildReEnterPasswordTextField(),
        ),
        _buildSubmitButton(),
      ],
    );
  }

  //********************************************************************** */
  //* All the fields are valid.  Now we take the info on the form to the
  //* next step.
  //********************************************************************** */
  void _submit() async {
    log.info('pressed contact electrician button.');
    final auth = Provider.of<AuthBase>(context);
    Member member = await auth.createAccount(context, _email, _password);
    if (member == null) {
      log.info('Member is null.');
      setState(() {});
    }
    if (member != null) {
      String _monitor = await member.assignMonitor(context);
      if (_monitor != null) {
        Map userRecordJson = member.toJson(
            address: _address,
            name: _name,
            phone: _phone,
            email: _email,
            monitor: _monitor);

        member.createUserRecord(userRecordJson);

        //*TODO: Go to set up electrician visit
      } else {
        log.info(
            'Error - no monitors available. This should have been caught already by waitlist.');
      }
    }
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
        enabled: isValidZip == true,
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
        enabled: isValidZip == true,
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
        enabled: isValidZip == true,
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
        enabled: isValidZip == true,
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
    bool showErrorText = !widget.passwordValidator.isValid(_password);
    return TextField(
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      decoration: InputDecoration(
        icon: Icon(Icons.lock, color: Colors.grey),
        labelText: 'Password',
        errorText: showErrorText ? widget.invalidPasswordErrorText : null,
        enabled: isValidZip == true,
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
    bool showErrorText = true;
    if (_password.isNotEmpty || _reEnterPassword.isNotEmpty) {
      showErrorText = !widget.reEnterPasswordValidator.isValid(value);
    }
    return TextField(
      controller: _reEnterPasswordController,
      focusNode: _reEnterPasswordFocusNode,
      decoration: InputDecoration(
        icon: Icon(Icons.lock, color: Colors.grey),
        labelText: 'Re-enter Password',
        errorText: showErrorText ? widget.invalidReEnterPasswordText : null,
        enabled: isValidZip == true,
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
    bool _submitEnabled = widget.emailValidator.isValid(_email) &&
        widget.textfieldValidator.isValid(_name) &&
        widget.phoneValidator.isValid(_phone) &&
        widget.textfieldValidator.isValid(_address) &&
        widget.passwordValidator.isValid(_password) &&
        widget.reEnterPasswordValidator
            .isValid(valueForReEnterPasswordValidator);

    return FormSubmitButton(
      text: 'Schedule an Electrician',
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

  _checkExpandText() {
    if (_name.isNotEmpty ||
        _email.isNotEmpty ||
        _phone.isNotEmpty ||
        _address.isNotEmpty ||
        _password.isNotEmpty ||
        _reEnterPassword.isNotEmpty && isValidZip) {
      expandFillInText = false;
    } else if (!isValidZip) {
      expandFillInText = false;
    } else {
      expandFillInText = true;
    }
  }
}

class _ZipCodeText extends StatelessWidget {
  const _ZipCodeText({
    Key key,
    @required this.expand,
  }) : super(key: key);

  final bool expand;

  @override
  Widget build(BuildContext context) {
    return AnimatedDefaultTextStyle(
      duration: const Duration(seconds: 1),
      style: expand
          ? TextStyle(
              fontSize: 30, color: Colors.red, fontWeight: FontWeight.bold)
          : TextStyle(
              fontSize: 10, color: Colors.grey, fontWeight: FontWeight.normal),
      child: Text(
        'Choose your Zipcode',
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _FillFormText extends StatelessWidget {
  const _FillFormText({
    Key key,
    @required this.expand,
  }) : super(key: key);

  final bool expand;

  @override
  Widget build(BuildContext context) {
    return AnimatedDefaultTextStyle(
      duration: const Duration(seconds: 1),
      style: expand
          ? TextStyle(
              fontSize: 30, color: Colors.red, fontWeight: FontWeight.bold)
          : TextStyle(
              fontSize: 10, color: Colors.grey, fontWeight: FontWeight.normal),
      child: Text(
        'Fill in Fields',
        textAlign: TextAlign.center,
      ),
    );
  }
}
