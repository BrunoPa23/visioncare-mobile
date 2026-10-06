import 'package:flutter/material.dart';

abstract class VoiceCommandHandler {
  void handle(String command, BuildContext context, {TextEditingController? controller});
}