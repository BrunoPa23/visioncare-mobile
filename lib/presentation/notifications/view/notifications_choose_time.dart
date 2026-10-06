import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visioncare_app/core/constants/app_primary_button_style.dart';
import 'package:visioncare_app/core/constants/app_secondary_button_style.dart';
import 'package:visioncare_app/presentation/notifications/viewmodel/notifications_viewmodel.dart';
import 'package:visioncare_app/presentation/shared/viewmodel/medicine_provider.dart';
import 'package:visioncare_app/presentation/shared/widgets/buttons/app_icon_button.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_body_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_button_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_subtitle_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_title_text.dart';

class NotificationsChooseTime extends ConsumerWidget {
  const NotificationsChooseTime({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsVM = ref.watch(notificationsViewModelProvider);
    final medicinesVM = ref.watch(medicineProvider.notifier);

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 60),
        child: Column(
          children: [
            AppTitleText("AÑADIR"),
            SizedBox(height: 20),
            AppBodyText(
              "¿A qué hora tomaras la medicación?",
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,  
              children: [
                AppSubtitleText("${notificationsVM.selectedTime.hour.toString().padLeft(2, '0')}:${notificationsVM.selectedTime.minute.toString().padLeft(2, '0')}", 
                  textAlign: TextAlign.center,
                  size: 60,
                ),
                SizedBox(width: 20),
                Semantics(
                  label: "Seleccionar hora",
                  button: true,
                  child: AppIconButton(
                    roundedRadius: 10,
                    size: 30,
                    icon: Icons.access_time, 
                    onPressed: () async {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: notificationsVM.selectedTime,
                      );
                      if (pickedTime != null && pickedTime != notificationsVM.selectedTime) {
                        notificationsVM.setSelectedTime(pickedTime);
                      }
                    }
                  ),
                )
              ],
            ),
            SizedBox(height: 40),
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
            SizedBox(height: 20),
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
    );
  }
}