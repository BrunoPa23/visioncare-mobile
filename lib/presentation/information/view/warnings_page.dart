import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visioncare_app/core/constants/app_colors.dart';
import 'package:visioncare_app/core/constants/app_secondary_button_style.dart';
import 'package:visioncare_app/presentation/information/viewmodel/warnings_view_model.dart';
import 'package:visioncare_app/presentation/shared/viewmodel/medicine_provider.dart';
import 'package:visioncare_app/presentation/shared/viewmodel/tts_view_model.dart';
import 'package:visioncare_app/presentation/shared/widgets/buttons/app_icon_button.dart';
import 'package:visioncare_app/presentation/shared/widgets/loading/app_loading_indicator.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_body_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_button_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_subtitle_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_title_text.dart';

class WarningsPage extends ConsumerWidget {
  const WarningsPage({super.key, required this.searchQuery});
  final String searchQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ttsVM = ref.watch(ttsViewModelProvider);
    final medicines = ref.watch(medicineProvider);

    if (medicines?.warnings != null && medicines!.warnings!.isNotEmpty) {
      debugPrint("✅ No hago llamado - warnings ya existen");
      return _buildWarningsContent(context, medicines!.warnings!, searchQuery, ttsVM);
    }

    debugPrint("🔁 Haciendo llamado API - warnings no existen");
    final asyncWarnings = ref.watch(warningsViewModelProvider(searchQuery));

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: asyncWarnings.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 80),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppTitleText("CARGANDO ADVERTENCIAS", textAlign: TextAlign.center),
                SizedBox(height: 60),
                AppLoadingIndicator(),
              ],
            ),
          ),
        ),
        error: (error, stack) => Center(
          child: AppBodyText("Error al cargar las advertencias"),
        ),
        data: (data) {
          Future.microtask(() {ref.read(medicineProvider.notifier).updateWarnings(data.warnings!);});
          debugPrint("✅ Llamado API exitoso - warnings actualizados");
          return _buildWarningsContent(context, data.warnings!, searchQuery, ttsVM);
        },
      ),
    );
  }

  Widget _buildWarningsContent(
    BuildContext context,
    List<String> warnings,
    String query,
    TTSViewModel ttsVM,
  ) {
    final isEmpty = warnings.isEmpty;

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
            AppBodyText("ADVERTENCIAS"),
            const SizedBox(height: 10),
            if (isEmpty)
              const AppBodyText("No se encontraron advertencias.")
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: warnings.length,
                itemBuilder: (context, index) {
                  return AppBodyText("- ${warnings[index]}", textAlign: TextAlign.start);
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
                    warnings.join(", "),
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
