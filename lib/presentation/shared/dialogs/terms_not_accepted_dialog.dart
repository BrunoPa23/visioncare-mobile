import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:visioncare_app/core/constants/app_colors.dart';
import 'package:visioncare_app/core/constants/app_primary_button_style.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_body_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_button_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_subtitle_text.dart';

class TermsNotAcceptedDialog extends StatelessWidget {
  const TermsNotAcceptedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.all(30),
      backgroundColor: AppColors.backgroundColor,
      title: AppSubtitleText(
        "TÉRMINOS NO ACEPTADOS",
        textAlign: TextAlign.center,
        size: 22,
      ),
      content: AppBodyText("Por favor, acepte los términos y condiciones para continuar.", size: 16, textAlign: TextAlign.center),
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