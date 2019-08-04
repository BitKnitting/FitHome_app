

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

class EmailAndPasswordValidators {
  final StringValidator emailValidator = EmailValidate();
  final StringValidator passwordValidator = NonEmptyStringValidator();
  final String invalidEmailErrorText = 'Not a valid email name.';
  final String invalidPasswordErrorText = 'Password can\'t be empty.';
  final String hintEmailText = 'Email';
  final String hintPasswordText = 'Password';
}
