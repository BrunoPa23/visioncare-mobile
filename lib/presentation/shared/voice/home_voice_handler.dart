import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:visioncare_app/presentation/shared/voice/voice_command_handler.dart';

class HomeVoiceHandler implements VoiceCommandHandler{
  @override
  void handle(String command, BuildContext context, {TextEditingController? controller}) {
    final cmd = command.toLowerCase();
    if (cmd.contains('medicinas')) {
      context.push('/medicines');
    } else if (cmd.contains('escanear')) {
      context.push('/scanning');
    } else if (cmd.contains('consultar')) {
      context.push('/search');
    } else if (cmd.contains('farmacias')) {
      context.push('/map');
    }
  }
}