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

// Validate the phone

class Validators {
  final StringValidator emailValidator = EmailValidate();
  final StringValidator textfieldValidator = NonEmptyStringValidator();
  final StringValidator phoneValidator = PhoneValidate();
  final String invalidEmailErrorText = 'Not a valid email name.';
  final String invalidTextfieldErrorText = 'can\'t be empty.';
  final String invalidPhoneErrorText = 'Not a valid phone number.';
  final String hintPhoneText = 'Mobile phone number';
  final String hintEmailText = 'Email';
}
