import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visioncare_app/core/constants/app_colors.dart';
import 'package:visioncare_app/core/constants/app_primary_button_style.dart';
import 'package:visioncare_app/core/constants/app_secondary_button_style.dart';
import 'package:visioncare_app/models/medicines.dart';
import 'package:visioncare_app/presentation/medicines/viewmodel/medicines_view_model.dart';
import 'package:visioncare_app/presentation/notifications/viewmodel/notifications_viewmodel.dart';
import 'package:visioncare_app/presentation/shared/utils/getRememberHourOnly.dart';
import 'package:visioncare_app/presentation/shared/viewmodel/medicine_provider.dart';
import 'package:visioncare_app/presentation/shared/widgets/loading/app_loading_indicator.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_body_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_button_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_subtitle_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_title_text.dart';

class MedicinesPage extends ConsumerWidget {
  const MedicinesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(getAllMedicinesProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 60),
          child: Column(
            children: [
              AppTitleText("MEDICINAS"),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: AppPrimaryButtonStyle.elevated,
                  onPressed: () {
                    ref.read(notificationsViewModelProvider).resetState();
                    ref.read(medicineProvider.notifier).clearMedicine();
                    context.pushReplacement('/notifications/input-medication');
                  },
                  child: AppButtonText("AÑADIR"),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: AppPrimaryButtonStyle.elevated,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Funcionalidad no implementada"))
                    );
                  },
                  child: AppButtonText("HISTORIAL"),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                 child: ElevatedButton(
                  onPressed: () {
                    context.pop();
                  },
                  child: AppButtonText("VOLVER"),
                  style: AppSecondaryButtonStyle.elevated
                ),
              ),
              vm.when(
                data: (data){
                  if (data.isEmpty) {
                    return Center(
                      child: Column(
                        children: [
                          SizedBox(height: 20),
                          AppSubtitleText("No hay medicinas registradas"),
                        ],
                      ),
                    );
                  }
                  return _buildContent(context, ref, data);
                } , 
                error: (error, stack) => Center(
                  child: AppTitleText("Error al cargar las medicinas: $error"),
                ),
                loading: () => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 20),
                      AppTitleText("CARGANDO MEDICINAS", textAlign: TextAlign.center),
                      SizedBox(height: 60),
                      AppLoadingIndicator(),
                    ],
                  ),
                )
              )
            ],
          ),
        ),
      )
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, List<Medicines> medicines) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: medicines.length,
      itemBuilder: (context, index) {
        final medicine = medicines[index];
        final deletingMap = ref.watch(deletingMedicinesProvider);
        final isDeleting = deletingMap[medicine.id]?.isLoading ?? false;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Card(
            shape: RoundedRectangleBorder(
              side: BorderSide(color: AppColors.secondaryColor, width: 3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppSubtitleText(
                    medicine.name!.toUpperCase(),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 8),
                  AppBodyText(
                    medicine.notifications == [] ? 'Sin días seleccionados' : 'Días: ${medicine.notifications!.map((e) => e.day).toSet().join(', ')}',
                  ),
                  AppBodyText(
                    medicine.notifications == [] ? 'Sin horas seleccionadas' :  'Hora: ${medicine.notifications!
                        .map((e) => getRememberHourOnly(e))
                        .toSet()
                        .join(', ')}',
                  ),
                  AppBodyText(
                    medicine.expirationDate == null ? 'Fecha de vencimiento: No encontrada' : 'Fecha de vencimiento: ${medicine.expirationDate}',
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      ref.watch(medicineProvider.notifier).setMedicine(medicine);
                      context.push('/information');
                    },
                    style: AppPrimaryButtonStyle.elevated,
                    child: AppButtonText("INFORMACIÓN"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {}, 
                    style: AppPrimaryButtonStyle.elevated,
                    child: AppButtonText('EDITAR'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: isDeleting
                        ? null
                        : () async {
                            await deleteMedicine(ref, medicine.id!);
                          },
                    style: AppSecondaryButtonStyle.elevated,
                    child: isDeleting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: AppLoadingIndicator(scale: 0.7, strokeWidth: 8,),
                          )
                        : AppButtonText('ELIMINAR'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}