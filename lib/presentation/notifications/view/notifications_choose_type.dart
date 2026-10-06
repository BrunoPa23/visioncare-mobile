import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visioncare_app/core/constants/app_primary_button_style.dart';
import 'package:visioncare_app/core/constants/app_secondary_button_style.dart';
import 'package:visioncare_app/presentation/notifications/viewmodel/notifications_viewmodel.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_body_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_button_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_title_text.dart';

class NotificationsChooseType extends ConsumerWidget {
  const NotificationsChooseType({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsVM = ref.watch(notificationsViewModelProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 60),
          child: Column(
            children: [
              AppTitleText("AÑADIR"),
              SizedBox(height: 20),
              AppBodyText("¿En qué momento tomaras la medicación?", 
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  style: AppPrimaryButtonStyle.elevated,
                  onPressed: (){
                    notificationsVM.setSelectedType(TypeTimeNotification.meals);
                    context.pushReplacement('/notifications/choose-food');
                  }, 
                  child: AppButtonText("COMIDAS")
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  style: AppPrimaryButtonStyle.elevated,
                  onPressed: (){
                    notificationsVM.setSelectedType(TypeTimeNotification.specificTime);
                    context.pushReplacement('/notifications/choose-time');
                  }, 
                  child: AppButtonText("HORA ESPECÍFICA")
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  style: AppPrimaryButtonStyle.elevated,
                  onPressed: (){
                    notificationsVM.setSelectedType(TypeTimeNotification.twoOrMoreTimes);
                    context.pushReplacement('/notifications/choose-iterations');
                  }, 
                  child: AppButtonText("2 VECES O MÁS")
                ),
              ),
              SizedBox(height: 40),
              Container(
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