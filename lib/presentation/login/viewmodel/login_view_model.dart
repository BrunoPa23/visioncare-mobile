import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visioncare_app/core/validation/credential_validator.dart';
import 'package:visioncare_app/enums/error_auth_type_enum.dart';
import 'package:visioncare_app/services/auth_service.dart';


final loginViewModelProvider =
    ChangeNotifierProvider.autoDispose<LoginViewModel>(
  (ref) => LoginViewModel(ref.read(authServiceProvider)),
);

class LoginViewModel extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoginButtonEnabled = ValueNotifier<bool>(false);
  bool isLoading = false;
  bool loginSuccessful = false;
  bool hasBadLogin = false;
  ErrorAuthType? errorAuthType = ErrorAuthType.none;

  final AuthService _authService;

  LoginViewModel(this._authService) {
    emailController.addListener(_checkLoginButtonEnabled);
    passwordController.addListener(_checkLoginButtonEnabled);
  }

  // Mensaje que se muestra debajo de la contraseña cuando el login falla
  String get errorMessage {
    switch (errorAuthType) {
      case ErrorAuthType.emptyFields:
        return 'Escribe tu correo y tu contraseña para continuar.';
      case ErrorAuthType.invalidEmail:
        return 'El correo no es válido. Revisa que tenga @ y un punto, por ejemplo nombre@correo.com.';
      case ErrorAuthType.invalidPassword:
        return 'La contraseña debe tener al menos 8 caracteres, con letras y números.';
      default:
        return 'La contraseña no coincide con este correo. Inténtalo otra vez.';
    }
  }

  void clearError() {
    if (!hasBadLogin) return;
    hasBadLogin = false;
    errorAuthType = ErrorAuthType.none;
    notifyListeners();
  }

  void clearFields() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      emailController.clear();
      passwordController.clear();
      notifyListeners();
    });
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      hasBadLogin = true;
      loginSuccessful = false;
      errorAuthType = ErrorAuthType.emptyFields;
      notifyListeners();
      return;
    }

    if (!CredentialValidator.isValidEmail(email)) {
      hasBadLogin = true;
      loginSuccessful = false;
      errorAuthType = ErrorAuthType.invalidEmail;
      notifyListeners();
      return;
    }

    if (!CredentialValidator.isValidPassword(password)) {
      hasBadLogin = true;
      loginSuccessful = false;
      errorAuthType = ErrorAuthType.invalidPassword;
      notifyListeners();
      return;
    }

    hasBadLogin = false;
    isLoading = true;
    notifyListeners();

    bool result = await _authService.login(email, password);

    isLoading = false;
    if (result) {
      loginSuccessful = true;
      clearFields();
    } else {
      hasBadLogin = true;
      loginSuccessful = false;
      errorAuthType = ErrorAuthType.none;
    }
    notifyListeners();
  }

  void _checkLoginButtonEnabled() {
   WidgetsBinding.instance.addPostFrameCallback((_) {
      isLoginButtonEnabled.value =
          emailController.text.isNotEmpty && passwordController.text.isNotEmpty;
    });
  }
}