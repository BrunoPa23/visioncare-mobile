import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visioncare_app/core/constants/app_border_enable.dart';
import 'package:visioncare_app/core/constants/app_border_focused.dart';
import 'package:visioncare_app/core/constants/app_colors.dart';
import 'package:visioncare_app/core/constants/app_primary_button_style.dart';
import 'package:visioncare_app/core/constants/app_text_label_style.dart';
import 'package:visioncare_app/enums/error_auth_type_enum.dart';
import 'package:visioncare_app/presentation/login/viewmodel/login_view_model.dart';
import 'package:visioncare_app/presentation/shared/dialogs/bad_login_dialog.dart';
import 'package:visioncare_app/presentation/shared/dialogs/invalid_password_email_dialog.dart';
import 'package:visioncare_app/presentation/shared/widgets/loading/app_loading_indicator.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_button_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_label_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_title_text.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
Widget build(BuildContext context, WidgetRef ref) {
  final vm = ref.watch(loginViewModelProvider);
  
  if (!vm.isLoading && vm.loginSuccessful) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.pushReplacement('/home');
    });
  }

  if(!vm.isLoading && vm.hasBadLogin) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) {
          vm.hasBadLogin = false;
          vm.clearFields();
          if (vm.errorAuthType == ErrorAuthType.invalidEmail) {
            return InvalidPasswordEmailDialog(errorAuthType: ErrorAuthType.invalidEmail);
          } else if (vm.errorAuthType == ErrorAuthType.invalidPassword) {
            return InvalidPasswordEmailDialog(errorAuthType: ErrorAuthType.invalidPassword);
          } else {
            return BadLoginDialog();
          }
        },
        barrierDismissible: false
      );
    });
  }

  return Scaffold(
    backgroundColor: AppColors.backgroundColor,
    body: vm.isLoading ? 
    const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppTitleText("COMPROBANDO CUENTA", textAlign: TextAlign.center),
              SizedBox(height: 60),
              AppLoadingIndicator(),
            ],
          ),
        ),
      )
    : SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo_app.png',
                width: 180,
                height: 180,
              ),
              const SizedBox(height: 30),
              TextField(
                style:  AppTextLabelStyle.style,
                controller: vm.emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  label: AppLabelText("Correo Electrónico"),
                  enabledBorder: AppBorderEnable.borderEnableTextField,
                  focusedBorder: AppBorderFocused.borderFocusedTextField,
                  contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                style:  AppTextLabelStyle.style,
                controller: vm.passwordController,
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
                decoration: InputDecoration(
                  label: AppLabelText("Contraseña"),
                  enabledBorder: AppBorderEnable.borderEnableTextField,
                  focusedBorder: AppBorderFocused.borderFocusedTextField,
                  contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                child: ValueListenableBuilder<bool>(
                  valueListenable: vm.isLoginButtonEnabled,
                  builder: (context, isEnabled, child) {
                    return ElevatedButton(
                      style: AppPrimaryButtonStyle.elevated,
                      onPressed: isEnabled ? () async {
                        await vm.login();
                      } : null,
                      child: AppButtonText("ENTRAR")
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  style: AppPrimaryButtonStyle.elevated,
                  onPressed: () {
                    context.push('/register');
                  },
                  child: AppButtonText("NO TENGO CUENTA", textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}