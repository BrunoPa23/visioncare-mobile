import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visioncare_app/core/constants/app_colors.dart';
import 'package:visioncare_app/presentation/shared/viewmodel/text_scale_notifier.dart';

class AppLabelText extends ConsumerWidget {
  final String text;
  final TextAlign? textAlign;
  final Color? color;

  const AppLabelText(
    this.text, {
    super.key,
    this.textAlign,
    this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scale = ref.watch(textScaleProvider);

    return Text(
      text,
      textAlign: textAlign,
      style: GoogleFonts.openSans(
        textStyle: TextStyle(
          fontSize: 24 * scale, 
          fontWeight: FontWeight.w600,
          color: color ?? AppColors.textColor.withAlpha(150),
        ),
      ),
      overflow: TextOverflow.ellipsis
    );
  }
}
