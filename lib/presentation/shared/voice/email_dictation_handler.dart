import 'package:flutter/material.dart';
import 'package:visioncare_app/presentation/shared/voice/voice_command_handler.dart';

/// Escribe en el campo de correo lo que la persona dicta,
/// convirtiendo "arroba", "punto" y "guion" en sus simbolos.
class EmailDictationHandler implements VoiceCommandHandler {
  @override
  void handle(String command, BuildContext context, {TextEditingController? controller}) {
    if (controller == null) return;
    final email = normalizeDictatedEmail(command);
    controller.value = TextEditingValue(
      text: email,
      selection: TextSelection.collapsed(offset: email.length),
    );
  }
}

String normalizeDictatedEmail(String text) {
  var email = text.toLowerCase().trim();
  email = email.replaceAll(RegExp(r'\s*arroba\s*'), '@');
  email = email.replaceAll(RegExp(r'\s*punto\s*'), '.');
  email = email.replaceAll(RegExp(r'\s*gui[oó]n bajo\s*'), '_');
  email = email.replaceAll(RegExp(r'\s*gui[oó]n\s*'), '-');
  email = email.replaceAll(RegExp(r'\s+'), '');

  const withAccent = 'áéíóúüñ';
  const withoutAccent = 'aeiouun';
  for (var i = 0; i < withAccent.length; i++) {
    email = email.replaceAll(withAccent[i], withoutAccent[i]);
  }
  return email;
}
