import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visioncare_app/core/constants/app_border_enable.dart';
import 'package:visioncare_app/core/constants/app_border_focused.dart';
import 'package:visioncare_app/core/constants/app_primary_button_style.dart';
import 'package:visioncare_app/core/constants/app_secondary_button_style.dart';
import 'package:visioncare_app/core/constants/app_text_label_style.dart';
import 'package:visioncare_app/models/medicines.dart';
import 'package:visioncare_app/presentation/information/viewmodel/search_view_model.dart';
import 'package:visioncare_app/presentation/shared/viewmodel/medicine_provider.dart';
import 'package:visioncare_app/presentation/shared/viewmodel/speech_view_model.dart';
import 'package:visioncare_app/presentation/shared/voice/information_voice_handler.dart';
import 'package:visioncare_app/presentation/shared/widgets/buttons/app_icon_button.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_button_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_label_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_title_text.dart';

class SearchPage extends ConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speechVM = ref.watch(speechViewModelProvider);
    final searchVM = ref.watch(searchViewModelProvider);
    
    speechVM.setCommandHandler(InformationVoiceHandler(), context, controller: searchVM.searchController);


    return Scaffold(
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppTitleText("CONSULTAR"),
                SizedBox(height: 80),
                AppIconButton(
                  icon: Icons.mic, 
                  onPressed: () {
                    if (speechVM.isAvailable) {
                      speechVM.isListening ? speechVM.stopListening() : speechVM.startListening();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("El reconocimiento de voz no está disponible en este dispositivo."))
                      );
                    }
                  },
                  size: 76,
                ),
                SizedBox(height: 30),
                Semantics(
                  hint: "Escribe aquí la medicina que buscas",
                  child: TextField(
                    controller: searchVM.searchController,
                    style: AppTextLabelStyle.style,
                    decoration: InputDecoration(
                      labelText: "¿Qué medicina buscas?",
                      labelStyle: AppTextLabelStyle.style.copyWith(overflow: TextOverflow.ellipsis),
                      enabledBorder: AppBorderEnable.borderEnableTextField,
                      focusedBorder: AppBorderFocused.borderFocusedTextField,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(medicineProvider.notifier).clearMedicine();
                      context.push('/information', extra: {'searchQuery': searchVM.searchController.text});
                    },
                    child: AppButtonText("BUSCAR"),
                    style: AppPrimaryButtonStyle.elevated
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(medicineProvider.notifier).clearMedicine();
                      context.pop();
                    },
                    child: AppButtonText("VOLVER"),
                    style: AppSecondaryButtonStyle.elevated
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}