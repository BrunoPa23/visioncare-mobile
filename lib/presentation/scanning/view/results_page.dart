import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:visioncare_app/core/constants/app_primary_button_style.dart';
import 'package:visioncare_app/core/constants/app_secondary_button_style.dart';
import 'package:visioncare_app/models/medicines.dart';
import 'package:visioncare_app/presentation/notifications/viewmodel/notifications_viewmodel.dart';
import 'package:visioncare_app/presentation/scanning/viewmodel/results_view_model.dart';
import 'package:visioncare_app/presentation/shared/viewmodel/medicine_provider.dart';
import 'package:visioncare_app/presentation/shared/widgets/loading/app_loading_indicator.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_body_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_button_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_subtitle_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_title_text.dart';

class ResultsPage extends ConsumerWidget {
  const ResultsPage({super.key, required this.imageFile});
  final XFile imageFile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultVM = ref.watch(resultViewModelProvider(imageFile));

    return Scaffold(
      body: resultVM.when(
        data: (data) => data.name == 'Error'
            ? _buildError(context, ref, data.description ?? 'No se pudo leer el medicamento.')
            : _buildResult(context, ref, data),
        error: (error, stackTrace) => _buildError(context, ref, error.toString()),
        loading: () => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          // Region en vivo: el lector de pantalla avisa que se esta analizando la foto
          child: Semantics(
            liveRegion: true,
            label: 'Analizando la imagen, espera un momento',
            child: const ExcludeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppTitleText("CARGANDO RESULTADOS", textAlign: TextAlign.center),
                  SizedBox(height: 60),
                  AppLoadingIndicator(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResult(BuildContext context, WidgetRef ref, Medicines data) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: AppSubtitleText("INFORMACIÓN CAPTURADA", textAlign: TextAlign.center),
            ),
            SizedBox(height: 30),
            AppBodyText("Nombre del medicamento: ${data.name}"),
            SizedBox(height: 10),
            AppBodyText("Fecha de vencimiento: ${data.expirationDate ?? 'No encontrada'}"),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: AppPrimaryButtonStyle.elevated,
                onPressed: () {
                  ref.read(medicineProvider.notifier).setMedicine(data);
                  context.push('/information', extra: {'searchQuery': data.name});
                },
                child: AppButtonText("CONSULTAR INFORMACIÓN", textAlign: TextAlign.center),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: AppPrimaryButtonStyle.elevated,
                onPressed: () {
                  ref.read(medicineProvider.notifier).setMedicine(data);
                  ref.read(notificationsViewModelProvider).resetState();
                  context.push('/notifications/choose-days');
                },
                child: AppButtonText("AÑADIR TRATAMIENTO", textAlign: TextAlign.center),
              ),
            ),
            SizedBox(height: 20),
            _buildBackButton(context, ref),
          ],
        ),
      ),
    );
  }

  // Antes el error dejaba la pantalla sin salida; ahora explica que paso y permite reintentar o volver
  Widget _buildError(BuildContext context, WidgetRef ref, String message) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: AppSubtitleText("NO SE PUDO LEER EL MEDICAMENTO", textAlign: TextAlign.center),
            ),
            SizedBox(height: 30),
            AppBodyText(message),
            SizedBox(height: 10),
            AppBodyText("Prueba con una foto más cercana, con buena luz y sin reflejos."),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: AppPrimaryButtonStyle.elevated,
                onPressed: () => ref.invalidate(resultViewModelProvider(imageFile)),
                child: AppButtonText("INTENTAR DE NUEVO", textAlign: TextAlign.center),
              ),
            ),
            SizedBox(height: 20),
            _buildBackButton(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: AppSecondaryButtonStyle.elevated,
        onPressed: () {
          ref.read(medicineProvider.notifier).clearMedicine();
          context.pop();
        },
        child: AppButtonText("VOLVER", textAlign: TextAlign.center),
      ),
    );
  }
}
