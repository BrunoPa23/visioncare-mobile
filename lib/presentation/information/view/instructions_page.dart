import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visioncare_app/core/constants/app_colors.dart';
import 'package:visioncare_app/core/constants/app_secondary_button_style.dart';
import 'package:visioncare_app/models/medicines.dart';
import 'package:visioncare_app/presentation/information/viewmodel/instructions_view_model.dart';
import 'package:visioncare_app/presentation/shared/viewmodel/medicine_provider.dart';
import 'package:visioncare_app/presentation/shared/viewmodel/tts_view_model.dart';
import 'package:visioncare_app/presentation/shared/widgets/buttons/app_icon_button.dart';
import 'package:visioncare_app/presentation/shared/widgets/loading/app_loading_indicator.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_body_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_button_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_subtitle_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_title_text.dart';

class InstructionsPage extends ConsumerWidget {
  const InstructionsPage({
    super.key,
    required this.searchQuery
  });

  final String searchQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ttsVM = ref.watch(ttsViewModelProvider);
    final medicines = ref.watch(medicineProvider);

    if (medicines?.instructions != null && medicines!.instructions!.isNotEmpty) {
      debugPrint("NO ESTOY HACIENDO LLAMADO");
      return _buildInstructionsContent(context, ref, medicines!.instructions, searchQuery, ttsVM);
    }

    debugPrint("ESTOY HACIENDO LLAMADO");
    final asyncInstructions = ref.watch(instructionsViewModelProvider(searchQuery));

    return Scaffold(
      body: asyncInstructions.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 80),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppTitleText("CARGANDO INSTRUCCIONES", textAlign: TextAlign.center),
                SizedBox(height: 60),
                AppLoadingIndicator(),
              ],
            ),
          ),
        ),
        error: (error, stack) => Center(
          child: AppBodyText("Error al cargar las instrucciones: $error"),
        ),
        data: (data) {
          Future.microtask(() {ref.read(medicineProvider.notifier).updateInstructions(data.instructions!);}); 
          debugPrint("✅ Llamado API exitoso - instrucciones actualizadas");
          return _buildInstructionsContent(context, ref, data.instructions, searchQuery, ttsVM);
          },
      ),
    );
  }

  Widget _buildInstructionsContent(BuildContext context, WidgetRef ref, List<String>? instructions, String query, TTSViewModel ttsVM) {
    final isEmpty = instructions == null || instructions.isEmpty;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppBodyText("Buscando..."),
            AppSubtitleText(query.toUpperCase()),
            const SizedBox(height: 30),
            AppBodyText("INSTRUCCIONES"),
            const SizedBox(height: 10),
            if (isEmpty)
              const AppBodyText("No se encontró información sobre las instrucciones."),
            if (!isEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: instructions!.length,
                itemBuilder: (context, index) {
                  return AppBodyText("- ${instructions[index]}", textAlign: TextAlign.start);
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
                    instructions?.join("\n") ?? "No se encontró información sobre las instrucciones del medicamento.",
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
