import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visioncare_app/core/constants/app_colors.dart';
import 'package:visioncare_app/core/constants/app_primary_button_style.dart';
import 'package:visioncare_app/core/constants/app_secondary_button_style.dart';
import 'package:visioncare_app/models/medicines.dart';
import 'package:visioncare_app/presentation/information/viewmodel/information_view_model.dart';
import 'package:visioncare_app/presentation/shared/viewmodel/medicine_provider.dart';
import 'package:visioncare_app/presentation/shared/viewmodel/tts_view_model.dart';
import 'package:visioncare_app/presentation/shared/widgets/buttons/app_icon_button.dart';
import 'package:visioncare_app/presentation/shared/widgets/loading/app_loading_indicator.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_body_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_button_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_title_text.dart';

class InformationPage extends ConsumerWidget {
  const InformationPage({
    super.key,
    required this.searchQuery,
  });

  final String searchQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ttsVM = ref.watch(ttsViewModelProvider);
    final medicine = ref.watch(medicineProvider);

    if (medicine != null && medicine.description != null) {
      debugPrint("YA EXISTE");
      return _buildContent(context, ref, medicine!, searchQuery, ttsVM);
    }

    debugPrint("HARE UN LLAMADO");
    final asyncInfo = ref.watch(searchInformationProvider(searchQuery.isEmpty ? medicine!.name! : searchQuery));
    
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: asyncInfo.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppTitleText("CARGANDO INFORMACIÓN", textAlign: TextAlign.center),
              SizedBox(height: 60),
              AppLoadingIndicator(),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: AppBodyText("Error al buscar información: $error", textAlign: TextAlign.center),
        ),
        data: (data){
          Future.microtask(() {ref.read(medicineProvider.notifier).setMedicine(data);});
          debugPrint("✅ Llamado API exitoso - información actualizada");
          return _buildContent(context, ref, data, searchQuery, ttsVM);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, Medicines data, String searchQuery, TTSViewModel ttsVM) {
    final isError = data.name == 'Error';

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppBodyText("Buscando..."),
            AppTitleText(isError ? "ERROR" : data.name!.toUpperCase()),
            const SizedBox(height: 30),
            AppBodyText(
              isError ? "No se encontró información" : data.description ?? "",
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 30),
            AppIconButton(
              icon: ttsVM.ttsState == TtsState.playing ? Icons.stop : Icons.play_arrow,
              onPressed: () {
                if (ttsVM.ttsState == TtsState.playing) {
                  ttsVM.setStopHandler();
                } else {
                  ttsVM.setStartHandler(data.description ?? "No se encontró información sobre el medicamento.");
                }
              },
              size: 50,
              color: AppColors.textColor,
              backgroundColor: AppColors.primaryColor,
            ),
            const SizedBox(height: 50),
            _buildNavigationButton(context, "EFECTOS SECUNDARIOS", '/side-effects', isError, data, searchQuery),
            const SizedBox(height: 10),
            _buildNavigationButton(context, "ADVERTENCIAS", '/warnings', isError, data, searchQuery),
            const SizedBox(height: 10),
            _buildNavigationButton(context, "INSTRUCCIONES", '/instructions', isError, data, searchQuery),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.pop(),
                style: AppSecondaryButtonStyle.elevated,
                child: const AppButtonText("VOLVER"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton(BuildContext context, String label, String route, bool isDisabled, Medicines data, String query) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isDisabled
            ? null
            : () => context.push(route, extra: {
                  'searchQuery': data.name ?? query,
                  'medicines': data,
                }),
        style: AppPrimaryButtonStyle.elevated,
        child: AppButtonText(label),
      ),
    );
  }
}
