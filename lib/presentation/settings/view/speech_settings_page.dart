import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visioncare_app/core/constants/app_colors.dart';
import 'package:visioncare_app/core/constants/app_icon_button_style.dart';
import 'package:visioncare_app/core/constants/app_primary_button_style.dart';
import 'package:visioncare_app/core/constants/app_secondary_button_style.dart';
import 'package:visioncare_app/presentation/shared/viewmodel/tts_view_model.dart';
import 'package:visioncare_app/presentation/shared/widgets/buttons/app_icon_button.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_button_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_subtitle_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_title_text.dart';

class SpeechSettingsPage extends ConsumerWidget {
  const SpeechSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ttsVM = ref.watch(ttsViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
                    child: AppTitleText("CONFIGURACIÓN DE VOZ", textAlign: TextAlign.center),
                  ),
                  AppIconButton(
                    icon: ttsVM.ttsState == TtsState.playing ? Icons.stop : Icons.play_arrow, 
                    onPressed: () {
                      if (ttsVM.ttsState == TtsState.playing) {
                        ttsVM.setStopHandler();
                      } else {
                        ttsVM.setStartHandler("Hola, este es un texto de prueba para la síntesis de voz.");
                      }
                    },
                    size: 100,
                    color: AppColors.textColor,
                    backgroundColor: AppColors.backgroundColor,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20,bottom: 60, left: 30, right: 30),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Container(
                              height: 5,
                              decoration: BoxDecoration(
                                color: AppColors.DisabledButtonColor.withAlpha(150),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Row(
                            children: [
                              Expanded(child: AppSubtitleText("VOLUMEN", textAlign: TextAlign.start)),
                              ElevatedButton(
                                onPressed: ttsVM.increaseVolume, 
                                style: AppPrimaryButtonStyle.elevated,
                                child: AppButtonText("+")),
                              SizedBox(width: 20),
                              ElevatedButton(
                                onPressed: ttsVM.decreaseVolume, 
                                style: AppPrimaryButtonStyle.elevated,
                                child: AppButtonText("-")),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(child: AppSubtitleText("VELOCIDAD", textAlign: TextAlign.start)),
                              ElevatedButton(
                                onPressed: ttsVM.increaseRate, 
                                style: AppPrimaryButtonStyle.elevated,
                                child: AppButtonText("+")),
                              SizedBox(width: 20), // Add some space between buttons
                              ElevatedButton(
                                onPressed: ttsVM.decreaseRate, 
                                style: AppPrimaryButtonStyle.elevated,
                                child: AppButtonText("-")),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(child: AppSubtitleText("TONO", textAlign: TextAlign.start)),
                              ElevatedButton(
                                onPressed: ttsVM.increasePitch, 
                                style: AppPrimaryButtonStyle.elevated,
                                child: AppButtonText("+")),
                              SizedBox(width: 20),
                              ElevatedButton(
                                onPressed: ttsVM.decreasePitch, 
                                style: AppPrimaryButtonStyle.elevated,
                                child: AppButtonText("-")),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Container(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: AppSecondaryButtonStyle.elevated,
                              onPressed: () {
                                context.pop();
                              },
                              child: const AppButtonText("VOLVER"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );}
      ),
    );
  }
}