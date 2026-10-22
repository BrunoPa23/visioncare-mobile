import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visioncare_app/presentation/shared/viewmodel/tts_view_model.dart';

/// Anuncia un resultado importante (por ejemplo el del escaneo o un recordatorio creado).
///
/// Con TalkBack o VoiceOver activo se envia al lector de pantalla, para no hablar encima de el.
/// Sin lector de pantalla se lee con la voz de la app, porque la persona puede no ver bien el texto.
void announceResult(BuildContext context, WidgetRef ref, String message) {
  if (MediaQuery.accessibleNavigationOf(context)) {
    SemanticsService.sendAnnouncement(
      View.of(context),
      message,
      Directionality.of(context),
      assertiveness: Assertiveness.assertive,
    );
  } else {
    ref.read(ttsViewModelProvider).setStartHandler(message);
  }
}
