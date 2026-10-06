import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:visioncare_app/core/constants/app_colors.dart';
import 'package:visioncare_app/core/constants/app_primary_button_style.dart';
import 'package:visioncare_app/enums/error_auth_type_enum.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_body_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_button_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_subtitle_text.dart';

class InvalidPasswordEmailDialog extends StatelessWidget {
  const InvalidPasswordEmailDialog({super.key, required this.errorAuthType});
  final ErrorAuthType errorAuthType;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.all(30),
      backgroundColor: AppColors.backgroundColor,
      title: AppSubtitleText(
        errorAuthType == ErrorAuthType.invalidEmail
            ? "CORREO ELECTRÓNICO INVÁLIDO"
            : "CONTRASEÑA INVÁLIDA",
        textAlign: TextAlign.center,
        size: 22,
      ),
      content: AppBodyText(
        errorAuthType == ErrorAuthType.invalidEmail
            ? "Por favor, ingrese un correo electrónico válido."
            : "Por favor, ingrese una contraseña válida. Debe tener al menos 8 caracteres entre letras y números.",
        size: 16,
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          style: AppPrimaryButtonStyle.elevated,
          onPressed: () {
            context.pop();
          },
          child: AppButtonText(
            "INTENTAR DE NUEVO",
            textAlign: TextAlign.center,
            size: 18,
            color: AppColors.textColor,
          ),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }
}