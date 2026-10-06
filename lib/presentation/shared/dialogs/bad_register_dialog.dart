import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:visioncare_app/core/constants/app_colors.dart';
import 'package:visioncare_app/core/constants/app_primary_button_style.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_body_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_button_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_subtitle_text.dart';

class BadRegisterDialog extends StatelessWidget {
  const BadRegisterDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.all(30),
      backgroundColor: AppColors.backgroundColor,
      title: AppSubtitleText(
        "CAMPOS INCOMPLETOS",
        textAlign: TextAlign.center,
        size: 22,
      ),
      // Error por campos incompletos
      content: AppBodyText("Por favor, complete todos los campos requeridos.", size: 16, textAlign: TextAlign.center),
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