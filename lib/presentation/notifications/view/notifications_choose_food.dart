import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visioncare_app/core/constants/app_primary_button_style.dart';
import 'package:visioncare_app/core/constants/app_secondary_button_style.dart';
import 'package:visioncare_app/presentation/notifications/viewmodel/notifications_viewmodel.dart';
import 'package:visioncare_app/presentation/shared/viewmodel/medicine_provider.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_body_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_button_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_title_text.dart';

class NotificationsChooseFood extends ConsumerWidget {
  const NotificationsChooseFood({super.key});

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
              AppBodyText("En que comida tomaras la medicación?", 
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              CheckboxListTile(
                title: AppBodyText("Desayuno"),
                value: notificationsVM.isBreakfastSelected, 
                onChanged: (bool? value) {
                  notificationsVM.toggleFoodSelection("Desayuno");
                }
              ),
              CheckboxListTile(
                title: AppBodyText("Almuerzo"),
                value: notificationsVM.isLunchSelected, 
                onChanged: (bool? value) {
                  notificationsVM.toggleFoodSelection("Almuerzo");
                }
              ),
              CheckboxListTile(
                title: AppBodyText("Cena"),
                value: notificationsVM.isDinnerSelected, 
                onChanged: (bool? value) {
                  notificationsVM.toggleFoodSelection("Cena");
                }
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: AppPrimaryButtonStyle.elevated,
                  onPressed: () {
                    notificationsVM.createNotification(context, ref);
                  }, 
                  child: AppButtonText("SIGUIENTE")
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
                  child: AppButtonText("VOLVER")
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}