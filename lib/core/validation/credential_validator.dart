/// Reglas de correo y contrasena que comparten el login y el registro.
class CredentialValidator {
  const CredentialValidator._();

  // Texto sin espacios, una @ y un dominio con punto; acepta alias con + y dominios largos (.museum, .co.uk)
  static final _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@.]{2,}$');

  // Al menos 8 caracteres con una letra y un numero; se permiten simbolos, espacios y letras con tilde
  static final _passwordRegex = RegExp(r'^(?=.*\p{L})(?=.*\d).{8,}$', unicode: true);

  static bool isValidEmail(String email) => _emailRegex.hasMatch(email);

  static bool isValidPassword(String password) => _passwordRegex.hasMatch(password);
}
