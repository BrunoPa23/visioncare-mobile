import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visioncare_app/core/constants/app_colors.dart';
import 'package:visioncare_app/core/constants/app_primary_button_style.dart';
import 'package:visioncare_app/core/constants/app_secondary_button_style.dart';
import 'package:visioncare_app/presentation/scanning/viewmodel/scanning_view_model.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_button_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_subtitle_text.dart';

class ScanningPage extends ConsumerWidget {
  const ScanningPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanningVM = ref.watch(scanningViewModelProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //SHOW IMAGE
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (scanningVM.image == null)
                      Icon(Icons.add_a_photo_outlined, size: 100, color: AppColors.textColor),
                    if (scanningVM.image == null) SizedBox(height: 10),
                    if (scanningVM.image == null) AppSubtitleText("SELECCIONA UNA IMAGEN"),
                    if (scanningVM.image == null) SizedBox(height: 30),
                    if (scanningVM.image != null)
                      Image.file(
                        File(scanningVM.image!.path),
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                    if (scanningVM.image != null)SizedBox(height: 20),
                    if (scanningVM.image == null)
                      ElevatedButton(
                        style: AppPrimaryButtonStyle.elevated,
                        onPressed: (){
                          scanningVM.pickImage();
                        }, 
                        child: AppButtonText("ABRIR GALERIA", size: 18)
                      ),
                    if (scanningVM.image == null) SizedBox(height: 10),
                    if (scanningVM.image == null)
                      ElevatedButton(
                        style: AppPrimaryButtonStyle.elevated,
                        onPressed: (){
                          scanningVM.takePicture();
                        }, 
                        child: AppButtonText("TOMAR UNA FOTO", size: 18)
                      ),
                    if (scanningVM.image != null)
                      ElevatedButton(
                        style: AppSecondaryButtonStyle.elevated,
                        onPressed: (){
                          scanningVM.clearImage();
                        }, 
                        child: AppButtonText("ELIMINAR IMAGEN", size: 18)
                      ),
                  ],
                )
              ),
            ),
            SizedBox(height: 20),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: AppPrimaryButtonStyle.elevated,
                    onPressed: scanningVM.image == null ? null : (){
                      context.push('/vision-results', 
                        extra: scanningVM.image
                      );
                    },
                    child: AppButtonText("ESCANEAR IMAGEN", textAlign: TextAlign.center)
                  ),
                ), 
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: AppSecondaryButtonStyle.elevated,
                    onPressed: (){
                      context.pop();
                    },
                    child: AppButtonText("VOLVER")
                  ),
                ),
              ],
            ), 
          ],
        ),
      ),
    );
  }
}