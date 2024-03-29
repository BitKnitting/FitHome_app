import 'package:email_validator/email_validator.dart';

abstract class StringValidator {
  bool isValid(String value);
}

// Validate the string contains at least one character.
class NonEmptyStringValidator implements StringValidator {
  bool isValid(String value) {
    return value.isNotEmpty;
  }
}

// Validate the syntax of the string is right for an email name.
class EmailValidate implements StringValidator {
  bool isValid(String value) {
    return EmailValidator.validate(value);
  }
}

// Validate the phone
class PhoneValidate implements StringValidator {
  static Pattern pattern =
      r'^(\([0-9]{3}\)|[0-9]{3})(-| |)[0-9]{3}(-|)[0-9]{4}$';
  RegExp regex = RegExp(pattern);
  bool isValid(String value) {
    if (regex.hasMatch(value)) {
      return true;
    }
    return false;
  }
}

class ZipcodeValidate implements StringValidator {
  static Pattern pattern = r'^[0-9]{5}(?:-[0-9]{4})?$';
  RegExp regex = RegExp(pattern);
  bool isValid(String value) {
    if (regex.hasMatch(value)) {
      return true;
    }
    return false;
  }
}
class TicketValidate implements StringValidator {
  static Pattern pattern = r'^[a-zA-Z0-9]{6}?$';
  RegExp regex = RegExp(pattern);
  bool isValid(String value) {
    if (regex.hasMatch(value)) {
      return true;
    }
    return false;
  }
}
class PasswordValidate implements StringValidator {
  static Pattern pattern = r'^[a-zA-Z0-9]{6,}?$';
  RegExp regex = RegExp(pattern);
  bool isValid(String value) {
    if (regex.hasMatch(value)) {
      return true;
    }
    return false;
  }
}

class ReEnterPasswordValidate implements StringValidator {
// We campare the password to the re-entered password.  However, our
// validators just take in a string up to this point. So we assume
// a string is passed in of the syntax <password>,<re-entered password>
  bool isValid(String value) {
    List<String> _passwordEntries = value.split(',');
    if (_passwordEntries.length != 2) {
      // String is not properly formated with <password>,<re-enter password>s
      return false;
    }
    if (_passwordEntries[0] == _passwordEntries[1]) {
      return true;
    }
    return false;
  }
}

class Validators {
  final StringValidator emailValidator = EmailValidate();
  final StringValidator textfieldValidator = NonEmptyStringValidator();
  final StringValidator phoneValidator = PhoneValidate();
  final StringValidator reEnterPasswordValidator = ReEnterPasswordValidate();
  final StringValidator zipcodeValidator = ZipcodeValidate();
  final StringValidator ticketValidator = TicketValidate();
  final StringValidator passwordValidator = PasswordValidate();

  final String invalidReEnterPasswordText = 'Must be the same as password.';
  final String invalidZipcodeText = "Not a valid zipcode.";
  final String invalidTicketErrorText = "Tickets are 6 characters or numbers.";
  final String invalidEmailErrorText = 'Not a valid email name.';
  final String invalidTextfieldErrorText = 'Can\'t be empty.';
  final String invalidPasswordErrorText = 'Passwords must be at least 6 characters.';
  final String invalidPhoneErrorText = 'Not a valid phone number.';
  final String hintPhoneText = 'SMS number';
  final String hintEmailText = 'Email';
}
