import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:visioncare_app/core/constants/app_primary_button_style.dart';
import 'package:visioncare_app/core/constants/app_secondary_button_style.dart';
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
        data: (data) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSubtitleText("INFORMACIÓN CAPTURADA", textAlign: TextAlign.center),
              SizedBox(height: 30),
              AppBodyText("Nombre del medicamento: ${data.name}"), 
              SizedBox(height: 10),
              AppBodyText("Fecha de vencimiento: ${data.expirationDate ?? 'No encontrada'}"),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: AppPrimaryButtonStyle.elevated,
                  onPressed: data.name =='Error' ? null : (){
                    ref.read(medicineProvider.notifier).setMedicine(data);
                    context.push('/information', 
                      extra: {
                        'searchQuery': data.name
                      }
                    );
                  },
                  child: AppButtonText("CONSULTAR INFORMACIÓN", textAlign: TextAlign.center,),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: AppPrimaryButtonStyle.elevated,
                  onPressed: data.name =='Error' ? null : (){
                    ref.read(medicineProvider.notifier).setMedicine(data);
                    ref.read(notificationsViewModelProvider).resetState();
                    context.push('/notifications/choose-days');
                  },
                  child: AppButtonText("AÑADIR TRATAMIENTO", textAlign: TextAlign.center,),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: AppSecondaryButtonStyle.elevated,
                  onPressed: () {
                    ref.read(medicineProvider.notifier).clearMedicine();
                    context.pop();
                  },
                  child: AppButtonText("VOLVER", textAlign: TextAlign.center,),
                ),
              )
            ],
                  ),
          ),
        ), 
        error: (error, stackTrace) => Center(
          child: AppBodyText("Error: $error"),
        ),
        loading: () => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppTitleText("CARGANDO RESULTADOS", textAlign: TextAlign.center),
              SizedBox(height: 60),
              AppLoadingIndicator()
            ],
          ),
        ),
      )
    );
  }
}