import 'package:flutter/widgets.dart';
import 'package:visioncare_app/presentation/shared/voice/voice_command_handler.dart';

class InformationVoiceHandler implements VoiceCommandHandler{
  @override
  void handle(String command, BuildContext context, {TextEditingController? controller}) {
    final cmd = command.toLowerCase();
    controller?.text = cmd;
  }
}