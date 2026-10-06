import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visioncare_app/core/constants/app_primary_button_style.dart';
import 'package:visioncare_app/core/constants/app_secondary_button_style.dart';
import 'package:visioncare_app/presentation/shared/viewmodel/text_scale_notifier.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_body_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_button_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_title_text.dart';

class TextSettingsPage extends ConsumerWidget {
  const TextSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textScale = ref.watch(textScaleProvider);
    final viewModel = ref.read(textScaleProvider.notifier);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AppTitleText("TAMAÑO DE TEXTO", textAlign: TextAlign.center),
                      Column(
                        children: [
                          AppTitleText("TITULO DE EJEMPLO", textAlign: TextAlign.center),
                          const SizedBox(height: 20),
                          const AppBodyText("Texto de ejemplo para mostrar el tamaño del texto.", textAlign: TextAlign.center),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                style: AppPrimaryButtonStyle.elevated,
                                onPressed: viewModel.decrease,
                                child: const AppButtonText("-"),
                              ),
                              AppTitleText(textScale.toStringAsFixed(1), textAlign: TextAlign.center),
                              ElevatedButton(
                                style: AppPrimaryButtonStyle.elevated,
                                onPressed: viewModel.increase,
                                child: const AppButtonText("+"),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: AppPrimaryButtonStyle.elevated,
                              onPressed: viewModel.reset,
                              child: const AppButtonText("REINICIAR"),
                            ),
                          ),
                          SizedBox(height: 20),
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
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}