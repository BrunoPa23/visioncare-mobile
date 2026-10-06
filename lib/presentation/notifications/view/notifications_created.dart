import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visioncare_app/core/constants/app_colors.dart';
import 'package:visioncare_app/core/constants/app_primary_button_style.dart';
import 'package:visioncare_app/presentation/medicines/viewmodel/medicines_view_model.dart';
import 'package:visioncare_app/presentation/notifications/viewmodel/notifications_viewmodel.dart';
import 'package:visioncare_app/presentation/shared/viewmodel/medicine_provider.dart';
import 'package:visioncare_app/presentation/shared/widgets/loading/app_loading_indicator.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_body_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_button_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_title_text.dart';

class NotificationsCreated extends ConsumerWidget {
  const NotificationsCreated({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsVM = ref.watch(notificationsViewModelProvider);

    // Modo carga
    if (notificationsVM.isLoading == true) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Center(
          child: AppLoadingIndicator(),
        ),
      );
    }

    // Modo error
    if (notificationsVM.isError == true) {
      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 60),
              const SizedBox(height: 20),
              const AppTitleText("Ocurrió un error"),
              const AppBodyText("No se pudo guardar la medicina o las notificaciones."),
              const SizedBox(height: 20),
              ElevatedButton(
                style: AppPrimaryButtonStyle.elevated,
                onPressed: () {
                  context.pop(); 
                },
                child: const AppButtonText("VOLVER"),
              ),
            ],
          ),
        ),
      );
    }

    // Modo éxito
    return Scaffold(
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(60),
                  ),
                  padding: const EdgeInsets.all(15),
                  child: Icon(
                    Icons.check,
                    size: 50,
                    color: AppColors.textColor,
                  ),
                ),
                const SizedBox(height: 40),
                const AppBodyText("Tu medicina", textAlign: TextAlign.center),
                AppTitleText(
                  notificationsVM.medicationNameController.text.isEmpty
                      ? ref.read(medicineProvider)!.name!.toUpperCase()
                      : notificationsVM.medicationNameController.text.toUpperCase(),
                  textAlign: TextAlign.center,
                ),
                const AppBodyText("Ha sido añadida correctamente", textAlign: TextAlign.center),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: AppPrimaryButtonStyle.elevated,
                    onPressed: () {
                      context.go('/home');
                      ref.read(medicineProvider.notifier).clearMedicine();
                      ref.invalidate(getAllMedicinesProvider);
                      notificationsVM.resetState();
                    },
                    child: const AppButtonText("TERMINAR"),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
