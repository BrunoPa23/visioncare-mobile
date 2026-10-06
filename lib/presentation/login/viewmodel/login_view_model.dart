import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visioncare_app/enums/error_auth_type_enum.dart';
import 'package:visioncare_app/presentation/shared/dialogs/bad_login_dialog.dart';
import 'package:visioncare_app/services/auth_service.dart';


final loginViewModelProvider =
    ChangeNotifierProvider.autoDispose<LoginViewModel>(
  (ref) => LoginViewModel(),
);

class LoginViewModel extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoginButtonEnabled = ValueNotifier<bool>(false);
  bool isLoading = false;
  bool loginSuccessful = false;
  bool hasBadLogin = false;
  ErrorAuthType? errorAuthType = ErrorAuthType.none;

  LoginViewModel() {
    emailController.addListener(_checkLoginButtonEnabled);
    passwordController.addListener(_checkLoginButtonEnabled);
  }

  void clearFields() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      emailController.clear();
      passwordController.clear();
      notifyListeners();
    });
  }

  Future<void> login() async {
    final email = emailController.text;
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      hasBadLogin = true;
      loginSuccessful = false;
      errorAuthType = ErrorAuthType.emptyFields;
      notifyListeners();
      return;
    }

    if (!isEmailValid(email)) {
      hasBadLogin = true;
      loginSuccessful = false;
      errorAuthType = ErrorAuthType.invalidEmail;
      notifyListeners();
      return;
    }

    if (!isPasswordValid(password)) {
      hasBadLogin = true;
      loginSuccessful = false;
      errorAuthType = ErrorAuthType.invalidPassword;
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    bool result = await AuthService().login(email, password);

    isLoading = false;
    if (result) {
      loginSuccessful = true;
      clearFields();
    } else {
      hasBadLogin = true;
      loginSuccessful = false;
    }
    notifyListeners();
  }

  void _checkLoginButtonEnabled() {
   WidgetsBinding.instance.addPostFrameCallback((_) {
      isLoginButtonEnabled.value =
          emailController.text.isNotEmpty && passwordController.text.isNotEmpty;
    });
  }

  bool isEmailValid(String email) {
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    return emailRegex.hasMatch(email);
  }

  bool isPasswordValid(String password) {
    final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
    return passwordRegex.hasMatch(password);
  }
}