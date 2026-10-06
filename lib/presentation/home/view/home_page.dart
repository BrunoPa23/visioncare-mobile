import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visioncare_app/core/constants/app_colors.dart';
import 'package:visioncare_app/core/constants/app_icon_button_style.dart';
import 'package:visioncare_app/core/constants/app_primary_button_style.dart';
import 'package:visioncare_app/presentation/home/view/home_viewmodel.dart';
import 'package:visioncare_app/presentation/shared/viewmodel/speech_view_model.dart';
import 'package:visioncare_app/presentation/shared/voice/home_voice_handler.dart';
import 'package:visioncare_app/presentation/shared/widgets/buttons/app_icon_button.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_title_text.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speechVM = ref.watch(speechViewModelProvider);
    speechVM.setCommandHandler(HomeVoiceHandler(), context);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                style: AppIconButtonStyle.button,
                icon: Icon(Icons.text_fields, color: AppColors.textColor, size: 30),
                onPressed: () {
                  context.push('/textSettings');
                },
              ),
              SizedBox(width: 10),
              IconButton(
                style: AppIconButtonStyle.button,
                icon: Icon(Icons.volume_up, color: AppColors.textColor, size: 30),
                onPressed: () {
                  context.push('/speechSettings');
                },
              ),
            ],
          ),
          SizedBox(height: 60),

          Center(
            child: AppIconButton(
              icon: Icons.mic, 
              onPressed: () {
                if (speechVM.isAvailable) {
                  speechVM.isListening ? speechVM.stopListening() : speechVM.startListening();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("El reconocimiento de voz no está disponible"))
                  );
                }
              },
              size: 76,
            ),
          ),

          SizedBox(height: 60),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (){
                context.push('/scanning');
              },
              style: AppPrimaryButtonStyle.elevated,
              child: Row(
                children: [
                  Icon(Icons.photo_camera, size: 50, color: AppColors.textColor),
                  SizedBox(width: 30),
                  Expanded(child: AppTitleText("ESCANEAR"))
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (){
                context.push('/medicines');
              },
              style: AppPrimaryButtonStyle.elevated,
              child: Row(
                children: [
                  Icon(Icons.medication, size: 50, color: AppColors.textColor),
                  SizedBox(width: 30),
                  Expanded(child: AppTitleText("MEDICINAS"))
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (){
                context.push('/search');
              },
              style: AppPrimaryButtonStyle.elevated,
              child: Row(
                children: [
                  Icon(Icons.search, size: 50, color: AppColors.textColor),
                  SizedBox(width: 30),
                  Expanded(child: AppTitleText("CONSULTAR"))
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (){
                context.push('/map');
              },
              style: AppPrimaryButtonStyle.elevated,
              child: Row(
                children: [
                  Icon(Icons.map, size: 50, color: AppColors.textColor),
                  SizedBox(width: 30),
                  Expanded(child: AppTitleText("FARMACIAS"))
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (){
                ref.read(homeViewmodelProvider).signOut(context, ref);
              },
              style: AppPrimaryButtonStyle.elevated,
              child: Row(
                children: [
                  Icon(Icons.logout, size: 50, color: AppColors.textColor),
                  SizedBox(width: 30),
                  Expanded(child: AppTitleText("CERRAR SESIÓN"))
                ],
              ),
            ),
          ),

        ],
      )
    );
  }
}