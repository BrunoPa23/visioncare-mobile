import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visioncare_app/core/constants/app_colors.dart';
import 'package:visioncare_app/core/constants/app_secondary_button_style.dart';
import 'package:visioncare_app/models/medicines.dart';
import 'package:visioncare_app/presentation/information/viewmodel/side_effects_view_model.dart';
import 'package:visioncare_app/presentation/shared/viewmodel/medicine_provider.dart';
import 'package:visioncare_app/presentation/shared/viewmodel/tts_view_model.dart';
import 'package:visioncare_app/presentation/shared/widgets/buttons/app_icon_button.dart';
import 'package:visioncare_app/presentation/shared/widgets/loading/app_loading_indicator.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_body_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_button_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_subtitle_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_title_text.dart';

class SideEffectsPage extends ConsumerWidget {
  const SideEffectsPage({super.key, required this.searchQuery});
  final String searchQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ttsVM = ref.watch(ttsViewModelProvider);
    final medicines = ref.watch(medicineProvider);

    if (medicines?.sideEffects != null && medicines!.sideEffects!.isNotEmpty) {
      debugPrint("✅ No hago llamado - sideEffects ya existen");
      return _buildSideEffectsContent(context, medicines!.sideEffects!, searchQuery, ttsVM);
    }

    debugPrint("🔁 Haciendo llamado API - sideEffects no existen");
    final asyncSideEffects = ref.watch(sideEffectsViewModelProvider(searchQuery));

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: asyncSideEffects.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 80),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppTitleText("CARGANDO EFECTOS SECUNDARIOS", textAlign: TextAlign.center),
                SizedBox(height: 60),
                AppLoadingIndicator(),
              ],
            ),
          ),
        ),
        error: (error, stack) => Center(
          child: AppBodyText("Error al cargar los efectos secundarios"),
        ),
        data: (data) {
          Future.microtask(() {ref.read(medicineProvider.notifier).updateSideEffects(data.sideEffects!);});
          debugPrint("✅ Llamado API exitoso - sideEffects actualizados");
          return _buildSideEffectsContent(context, data.sideEffects!, searchQuery, ttsVM);
        },
      ),
    );
  }

  Widget _buildSideEffectsContent(
    BuildContext context,
    List<String> sideEffects,
    String query,
    TTSViewModel ttsVM,
  ) {
    final isEmpty = sideEffects.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppBodyText("Buscando..."),
            AppSubtitleText(query.toUpperCase()),
            const SizedBox(height: 30),
            AppBodyText("EFECTOS SECUNDARIOS"),
            const SizedBox(height: 10),
            if (isEmpty)
              const AppBodyText("No se encontraron efectos secundarios.")
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sideEffects.length,
                itemBuilder: (context, index) {
                  return AppBodyText("- ${sideEffects[index]}", textAlign: TextAlign.start);
                },
              ),
            const SizedBox(height: 30),
            AppIconButton(
              icon: ttsVM.ttsState == TtsState.playing ? Icons.stop : Icons.play_arrow,
              onPressed: () {
                if (ttsVM.ttsState == TtsState.playing) {
                  ttsVM.setStopHandler();
                } else {
                  ttsVM.setStartHandler(
                    sideEffects.join(", "),
                  );
                }
              },
              size: 50,
              color: AppColors.textColor,
              backgroundColor: AppColors.primaryColor,
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: AppSecondaryButtonStyle.elevated,
                child: const AppButtonText("VOLVER"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
