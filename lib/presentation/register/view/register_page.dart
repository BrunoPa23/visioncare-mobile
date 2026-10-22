import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visioncare_app/core/constants/app_border_enable.dart';
import 'package:visioncare_app/core/constants/app_border_focused.dart';
import 'package:visioncare_app/core/constants/app_colors.dart';
import 'package:visioncare_app/core/constants/app_primary_button_style.dart';
import 'package:visioncare_app/core/constants/app_text_label_style.dart';
import 'package:visioncare_app/enums/error_auth_type_enum.dart';
import 'package:visioncare_app/presentation/register/viewmodel/register_view_model.dart';
import 'package:visioncare_app/presentation/shared/dialogs/bad_register_dialog.dart';
import 'package:visioncare_app/presentation/shared/dialogs/invalid_password_email_dialog.dart';
import 'package:visioncare_app/presentation/shared/dialogs/terms_not_accepted_dialog.dart';
import 'package:visioncare_app/presentation/shared/viewmodel/text_scale_notifier.dart';
import 'package:visioncare_app/presentation/shared/widgets/loading/app_loading_indicator.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_body_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_button_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_label_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_title_text.dart';

class RegisterPage extends ConsumerWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(registerViewModelProvider);
    final scale = ref.watch(textScaleProvider);

    if(!vm.isLoading && vm.hasBadRegister) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (context) {
            vm.hasBadRegister = false;
            if(vm.errorAuthType == ErrorAuthType.invalidPassword) {
              return InvalidPasswordEmailDialog(errorAuthType: ErrorAuthType.invalidPassword);
            } else if(vm.errorAuthType == ErrorAuthType.invalidEmail) {
              return InvalidPasswordEmailDialog(errorAuthType: ErrorAuthType.invalidEmail);
            } else if(vm.errorAuthType == ErrorAuthType.termsNotAccepted){
              return TermsNotAcceptedDialog();
            } else {
              return BadRegisterDialog();
            }
          },
          barrierDismissible: false
        );
      });
    }

    if(!vm.isLoading && vm.registerSuccessful) {
      Future.delayed(Duration.zero, () {
        if (!context.mounted) return;
        context.pushReplacement('/home');
      });
    }

    return vm.isLoading ? 
    Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            // El lector de pantalla anuncia el cambio de estado sin que la persona tenga que buscarlo
            child: Semantics(
              liveRegion: true,
              label: 'Registrando tu cuenta, espera un momento',
              child: const ExcludeSemantics(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppTitleText("REGISTRANDO CUENTA", textAlign: TextAlign.center),
                    SizedBox(height: 60),
                    AppLoadingIndicator(),
                  ],
                ),
              ),
            ),
          ),
        ),
    )
    : Scaffold(
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 60.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(child: Semantics(header: true, child: AppTitleText("REGÍSTRATE"))),
                SizedBox(height: 40),
                TextField(
                  controller: vm.nameController,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.givenName],
                  style: AppTextLabelStyle.style,
                  decoration: InputDecoration(
                    label: AppLabelText("Nombre"),
                    enabledBorder: AppBorderEnable.borderEnableTextField,
                    focusedBorder: AppBorderFocused.borderFocusedTextField,
                    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                  ),
                ),
                SizedBox(height: 40),
                TextField(
                  controller: vm.lastNameController,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.familyName],
                  style: AppTextLabelStyle.style,
                  decoration: InputDecoration(
                    label: AppLabelText("Apellido"),
                    enabledBorder: AppBorderEnable.borderEnableTextField,
                    focusedBorder: AppBorderFocused.borderFocusedTextField,
                    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                  ),
                ),
                SizedBox(height: 40),
                TextField(
                  controller: vm.emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  style: AppTextLabelStyle.style,
                  decoration: InputDecoration(
                    label: AppLabelText("Correo electrónico"),
                    enabledBorder: AppBorderEnable.borderEnableTextField,
                    focusedBorder: AppBorderFocused.borderFocusedTextField,
                    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                  ),
                ),
                SizedBox(height: 30),
                TextField(
                  controller: vm.passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                  style: AppTextLabelStyle.style,
                  decoration: InputDecoration(
                    label: AppLabelText("Contraseña"),
                    // La regla se muestra antes de escribir para no descubrirla recien con el error
                    helperText: 'Al menos 8 caracteres, con letras y números.',
                    helperMaxLines: 3,
                    helperStyle: TextStyle(fontSize: 16 * scale, color: AppColors.textColor),
                    enabledBorder: AppBorderEnable.borderEnableTextField,
                    focusedBorder: AppBorderFocused.borderFocusedTextField,
                    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                  ),
                ),
                SizedBox(height: 30),
                ExcludeSemantics(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AppBodyText("Grado de discapacidad visual"),
                  ),
                ),
                SizedBox(height: 10),
                Semantics(
                  label: 'Grado de discapacidad visual',
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: DropdownButton<String>(
                      focusColor: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                      iconSize: 30,
                      style: AppTextLabelStyle.style,
                      underline: Container(height: 0),
                      items: vm.visualDegrees
                          .map((degree) => DropdownMenuItem<String>(
                                value: degree,
                                child: Text(degree),
                              ))
                          .toList(),
                      value: vm.selectedDegree,
                      onChanged: (value) {
                        if (value != null) {
                          vm.setSelectedDegree(value);
                        }
                      },
                      isExpanded: true,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Semantics(
                  hint: "Toca para abrir el selector de fecha de nacimiento",
                  child: TextField(
                    controller: vm.dobController,
                    readOnly: true,
                    style: AppTextLabelStyle.style,
                    decoration: InputDecoration(
                      label: AppLabelText("Fecha de nacimiento"),
                      enabledBorder: AppBorderEnable.borderEnableTextField,
                      focusedBorder: AppBorderFocused.borderFocusedTextField,
                      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        vm.dateOfBirth = date;
                        vm.dobController.text = "${date.day}/${date.month}/${date.year}";
                      }
                    },
                  ),
                ),
                SizedBox(height: 30),
                CheckboxListTile(
                  contentPadding: EdgeInsets.all(0),
                  checkColor: AppColors.textColor,
                  activeColor: AppColors.primaryColor,
                  title: AppBodyText("Acepto los términos y condiciones"),
                  value: vm.isChecked,
                  onChanged: (value) {
                    if (value != null) {
                      vm.toggleCheckbox(value);
                    }
                  },
                ),
                SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: vm.isButtonRegisterEnabled,
                    builder: (context, isEnabled, child) {
                      return ElevatedButton(
                        style: AppPrimaryButtonStyle.elevated,
                        onPressed:() async {
                          await vm.register();
                        },
                      child: AppButtonText("REGISTRARSE"),
                    );
                    },
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