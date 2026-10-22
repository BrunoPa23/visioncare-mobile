import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visioncare_app/core/constants/app_colors.dart';
import 'package:visioncare_app/core/constants/app_primary_button_style.dart';
import 'package:visioncare_app/core/constants/app_secondary_button_style.dart';
import 'package:visioncare_app/enums/theme_preference_enum.dart';
import 'package:visioncare_app/presentation/shared/viewmodel/text_scale_notifier.dart';
import 'package:visioncare_app/presentation/shared/viewmodel/theme_preference_notifier.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_body_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_button_text.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_subtitle_text.dart';
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
                      const SizedBox(height: 40),
                      const _ThemeSelector(),
                      const SizedBox(height: 40),
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: AppPrimaryButtonStyle.elevated,
                              onPressed: viewModel.reset,
                              child: const AppButtonText("REINICIAR"),
                            ),
                          ),
                          SizedBox(height: 20),
                          SizedBox(
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

class _ThemeSelector extends ConsumerWidget {
  const _ThemeSelector();

  static const _options = [
    (value: ThemePreference.light, label: 'CLARO', icon: Icons.light_mode_outlined),
    (value: ThemePreference.dark, label: 'OSCURO', icon: Icons.dark_mode_outlined),
    (value: ThemePreference.system, label: 'IGUAL QUE EL TELÉFONO', icon: Icons.phone_android),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(themePreferenceProvider);
    final notifier = ref.read(themePreferenceProvider.notifier);

    return Column(
      children: [
        const AppSubtitleText("TEMA", textAlign: TextAlign.center),
        const SizedBox(height: 8),
        const AppBodyText(
          "Por ahora el tema oscuro se aplica en el inicio de sesión.",
          textAlign: TextAlign.center,
          size: 16,
        ),
        const SizedBox(height: 16),
        for (final option in _options) ...[
          Semantics(
            selected: option.value == selected,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: option.value == selected
                    ? AppPrimaryButtonStyle.elevated
                    : ElevatedButton.styleFrom(
                        backgroundColor: AppColors.backgroundColor,
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        side: const BorderSide(color: AppColors.textColor, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                onPressed: () => notifier.set(option.value),
                child: Row(
                  children: [
                    Icon(
                      option.value == selected ? Icons.check_circle : option.icon,
                      size: 30,
                      color: AppColors.textColor,
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: AppButtonText(option.label, size: 20)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}