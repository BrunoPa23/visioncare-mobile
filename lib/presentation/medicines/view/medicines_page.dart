import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visioncare_app/core/constants/app_colors.dart';
import 'package:visioncare_app/core/constants/app_primary_button_style.dart';
import 'package:visioncare_app/core/constants/app_secondary_button_style.dart';
import 'package:visioncare_app/models/medicines.dart';
import 'package:visioncare_app/presentation/medicines/viewmodel/medicines_view_model.dart';
import 'package:visioncare_app/presentation/notifications/viewmodel/notifications_viewmodel.dart';
import 'package:visioncare_app/presentation/shared/utils/get_remember_hour_only.dart';
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
              Semantics(header: true, child: AppTitleText("MEDICINAS")),
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
                  style: AppSecondaryButtonStyle.elevated,
                  child: AppButtonText("VOLVER"),
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
                error: (error, stack) => Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Semantics(
                    liveRegion: true,
                    child: AppSubtitleText("No se pudieron cargar tus medicinas: $error", textAlign: TextAlign.center),
                  ),
                ),
                loading: () => Center(
                  child: Semantics(
                    liveRegion: true,
                    label: 'Cargando tus medicinas',
                    child: const ExcludeSemantics(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 20),
                          AppTitleText("CARGANDO MEDICINAS", textAlign: TextAlign.center),
                          SizedBox(height: 60),
                          AppLoadingIndicator(),
                        ],
                      ),
                    ),
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
        final name = medicine.name ?? 'Sin nombre';
        final notifications = medicine.notifications ?? [];
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
                  // Los datos de la tarjeta se leen juntos, antes de sus botones
                  MergeSemantics(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Semantics(
                          header: true,
                          child: AppSubtitleText(name.toUpperCase(), textAlign: TextAlign.start),
                        ),
                        const SizedBox(height: 8),
                        AppBodyText(
                          notifications.isEmpty ? 'Sin días seleccionados' : 'Días: ${notifications.map((e) => e.day).toSet().join(', ')}',
                        ),
                        AppBodyText(
                          notifications.isEmpty ? 'Sin horas seleccionadas' : 'Hora: ${notifications
                              .map((e) => getRememberHourOnly(e))
                              .toSet()
                              .join(', ')}',
                        ),
                        AppBodyText(
                          medicine.expirationDate == null ? 'Fecha de vencimiento: No encontrada' : 'Fecha de vencimiento: ${medicine.expirationDate}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      ref.watch(medicineProvider.notifier).setMedicine(medicine);
                      context.push('/information');
                    },
                    style: AppPrimaryButtonStyle.elevated,
                    child: _buttonLabel("INFORMACIÓN", 'Ver la información de $name'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {}, 
                    style: AppPrimaryButtonStyle.elevated,
                    child: _buttonLabel('EDITAR', 'Editar $name'),
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
                        ? Semantics(
                            label: 'Eliminando $name',
                            child: const SizedBox(
                              width: 20,
                              height: 20,
                              child: ExcludeSemantics(child: AppLoadingIndicator(scale: 0.7, strokeWidth: 8,)),
                            ),
                          )
                        : _buttonLabel('ELIMINAR', 'Eliminar $name'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // El texto visible es corto; el lector de pantalla dice tambien de que medicina se trata
  Widget _buttonLabel(String text, String semanticLabel) {
    return Semantics(
      label: semanticLabel,
      child: ExcludeSemantics(child: AppButtonText(text)),
    );
  }
}
