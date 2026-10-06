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

class NotificationsChooseIterations extends ConsumerWidget {
  const NotificationsChooseIterations({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsVM = ref.watch(notificationsViewModelProvider);
    final medicinesVM = ref.watch(medicineProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
          child: Column(
            children: [
              AppTitleText("AÑADIR"),
              const SizedBox(height: 20),
              AppBodyText("¿Cuantas veces al día tomaras la medicación?", 
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              CheckboxListTile(
                title: AppBodyText("Cada 4 horas"),
                value: notificationsVM.isEvery4HoursSelected,
                onChanged: (bool? value) {
                  notificationsVM.toggleIterationSelection("Cada 4 horas");
                }
              ),
              CheckboxListTile(
                title: AppBodyText("Cada 6 horas"),
                value: notificationsVM.isEvery6HoursSelected,
                onChanged: (bool? value) {
                  notificationsVM.toggleIterationSelection("Cada 6 horas");
                }
              ),
              CheckboxListTile(
                title: AppBodyText("Cada 8 horas"),
                value: notificationsVM.isEvery8HoursSelected,
                onChanged: (bool? value) {
                  notificationsVM.toggleIterationSelection("Cada 8 horas");
                }
              ),
              //12
              CheckboxListTile(
                title: AppBodyText("Cada 12 horas"),
                value: notificationsVM.isEvery12HoursSelected,
                onChanged: (bool? value) {
                  notificationsVM.toggleIterationSelection("Cada 12 horas");
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
        )
      ),
    );
  }
}