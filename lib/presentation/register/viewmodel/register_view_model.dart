import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visioncare_app/enums/error_auth_type_enum.dart';
import 'package:visioncare_app/models/user.dart';
import 'package:visioncare_app/services/auth_service.dart';

final registerViewModelProvider =
    ChangeNotifierProvider.autoDispose<RegisterViewModel>(
  (ref) => RegisterViewModel(),
);

class RegisterViewModel extends ChangeNotifier {
  final dobController = TextEditingController();
  DateTime? dateOfBirth;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final lastNameController = TextEditingController();
  final isButtonRegisterEnabled = ValueNotifier<bool>(false);
  final List<String> visualDegrees = ["Leve", "Moderada", "Grave", "Ceguera"];
  String _selectedDegree = 'Leve';
  bool isChecked = false;
  bool hasBadRegister = false;
  bool isLoading = false;
  bool registerSuccessful = false;
  ErrorAuthType? errorAuthType = ErrorAuthType.none;

  String get selectedDegree => _selectedDegree;

  RegisterViewModel() {
    emailController.addListener(_checkRegisterButtonEnabled);
    passwordController.addListener(_checkRegisterButtonEnabled);
    nameController.addListener(_checkRegisterButtonEnabled);
    lastNameController.addListener(_checkRegisterButtonEnabled);
    dobController.addListener(_checkRegisterButtonEnabled);
  }
  
  void setSelectedDegree(String degree) {
    _selectedDegree = degree;
    notifyListeners();
  }

  void toggleCheckbox(bool value) {
    isChecked = value; 
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _checkRegisterButtonEnabled(){
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isButtonRegisterEnabled.value = 
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        nameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        dobController.text.isNotEmpty &&
        isChecked;
    notifyListeners();
    });
  } 

  Future<void> register() async {
    final email = emailController.text;
    final password = passwordController.text;
    final name = nameController.text;
    final lastName = lastNameController.text;
    final birthday = dateOfBirth;

    if (!isChecked) {
      hasBadRegister = true;
      errorAuthType = ErrorAuthType.termsNotAccepted;
      notifyListeners();
      return;
    }

    if (email.isEmpty || password.isEmpty || name.isEmpty || lastName.isEmpty || birthday == null) {
      hasBadRegister = true;
      errorAuthType = ErrorAuthType.emptyFields;
      notifyListeners();
      return;
    }

    if (!isEmailValid(email)) {
      hasBadRegister = true;
      errorAuthType = ErrorAuthType.invalidEmail;
      notifyListeners();
      return;
    }

    if (!isPasswordValid(password)) {
      hasBadRegister = true;
      errorAuthType = ErrorAuthType.invalidPassword;
      notifyListeners();
      return;
    }

    final User user = User(
      email: email,
      password: password,
      name: name,
      lastName: lastName,
      birthday: birthday,
      visualDegree: selectedDegree,
    );
    
    isLoading = true;
    notifyListeners();
    bool result = await AuthService().signUp(user);
    
    isLoading = false;
    notifyListeners();

    if (result) {
      registerSuccessful = true;
      emailController.clear();
      passwordController.clear();
      nameController.clear();
      lastNameController.clear();
      dobController.clear();
      dateOfBirth = null;
      _selectedDegree = 'Leve';
      isChecked = false;
      notifyListeners();
    } else {
      hasBadRegister = true;
      notifyListeners();
    }
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