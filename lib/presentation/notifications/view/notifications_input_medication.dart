import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visioncare_app/core/constants/app_border_enable.dart';
import 'package:visioncare_app/core/constants/app_border_focused.dart';
import 'package:visioncare_app/core/constants/app_primary_button_style.dart';
import 'package:visioncare_app/core/constants/app_secondary_button_style.dart';
import 'package:visioncare_app/core/constants/app_text_label_style.dart';
import 'package:visioncare_app/presentation/notifications/viewmodel/notifications_viewmodel.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_body_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_button_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_label_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_title_text.dart';

class NotificationsInputMedication extends ConsumerWidget {
  const NotificationsInputMedication({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsVM = ref.watch(notificationsViewModelProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
          child: Column(
            children: [
              AppTitleText("AÑADIR"),
              const SizedBox(height: 20),
              AppBodyText("¿Como se llama la medicación?", 
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              TextField(
                controller: notificationsVM.medicationNameController,
                style: AppTextLabelStyle.style,
                decoration: InputDecoration(
                  label: AppLabelText("Nombre de la medicación"),
                  enabledBorder: AppBorderEnable.borderEnableTextField,
                  focusedBorder: AppBorderFocused.borderFocusedTextField,
                  contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: AppPrimaryButtonStyle.elevated,
                  onPressed: () {
                    context.pushReplacement('/notifications/choose-days');
                  }, 
                  child: AppButtonText("SIGUIENTE"),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: AppSecondaryButtonStyle.elevated,
                  onPressed: () {
                    context.pop();
                  }, 
                  child: AppButtonText("VOLVER"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}