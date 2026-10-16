import 'package:form_field_validator/form_field_validator.dart';
final passwordValidator = MultiValidator([
  RequiredValidator(errorText: 'Password is required'),
  MinLengthValidator(8, errorText: 'Password must be at least 8 chars long'),
  PatternValidator(r'(?=.*?[#?!@$%^&*-])', errorText: 'Password must have at least one special caracter'),
]);

final emailValidator = MultiValidator([
  RequiredValidator(errorText: 'Email is required'),
  EmailValidator(errorText: 'Enter a valid email'),
]);

// Compara la contraseña original con la confirmación
String? validateConfirmPassword(String? originalPassword, String? confirmPassword) {
if (confirmPassword == null || confirmPassword.isEmpty) {
return 'Por favor, confirma tu contraseña';
}
if (originalPassword != confirmPassword) {
return 'Las contraseñas no coinciden';
}
return null;
}
// final passwordconfirmationvalidator = MultiValidator([
//   RequiredValidator(errorText: 'Password confirmation is required'),
//
// ]);

// validador para las contraseñas