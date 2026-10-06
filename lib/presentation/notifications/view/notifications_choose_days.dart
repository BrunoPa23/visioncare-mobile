import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visioncare_app/core/constants/app_primary_button_style.dart';
import 'package:visioncare_app/core/constants/app_secondary_button_style.dart';
import 'package:visioncare_app/presentation/notifications/viewmodel/notifications_viewmodel.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_body_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_button_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_title_text.dart';

class NotificationsChooseDays extends ConsumerWidget {
  const NotificationsChooseDays({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsVM = ref.watch(notificationsViewModelProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
          child: Column(
            children: [
              const AppTitleText("AÑADIR"),
              const SizedBox(height: 20),
              AppBodyText("¿Qué días tomaras la medicación?", 
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              CheckboxListTile(
                title: AppBodyText("Lunes"),
                value: notificationsVM.isMondaySelected, 
                onChanged: (bool? value) {
                  notificationsVM.toggleDaySelection("Lunes");
                },
              ),
              CheckboxListTile(
                title: AppBodyText("Martes"),
                value: notificationsVM.isTuesdaySelected, 
                onChanged: (bool? value) {
                  notificationsVM.toggleDaySelection("Martes");
                },
              ),
              CheckboxListTile(
                title: AppBodyText("Miercoles"),
                value: notificationsVM.isWednesdaySelected, 
                onChanged: (bool? value) {
                  notificationsVM.toggleDaySelection("Miercoles");
                },
              ),
              CheckboxListTile(
                title: AppBodyText("Jueves"),
                value: notificationsVM.isThursdaySelected, 
                onChanged: (bool? value) {
                  notificationsVM.toggleDaySelection("Jueves");
                },
              ),
              CheckboxListTile(
                title: AppBodyText("Viernes"),
                value: notificationsVM.isFridaySelected, 
                onChanged: (bool? value) {
                  notificationsVM.toggleDaySelection("Viernes");
                },
              ),
              CheckboxListTile(
                title: AppBodyText("Sabado"),
                value: notificationsVM.isSaturdaySelected, 
                onChanged: (bool? value) {
                  notificationsVM.toggleDaySelection("Sabado");
                },
              ),
              CheckboxListTile(
                title: AppBodyText("Domingo"),
                value: notificationsVM.isSundaySelected, 
                onChanged: (bool? value) {
                  notificationsVM.toggleDaySelection("Domingo");
                },
              ),
              const SizedBox(height: 40),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  style: AppPrimaryButtonStyle.elevated,
                  onPressed: (){
                    context.pushReplacement("/notifications/choose-type");
                  },
                  child: AppButtonText("SIGUIENTE")
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  style: AppSecondaryButtonStyle.elevated,
                  onPressed: (){
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