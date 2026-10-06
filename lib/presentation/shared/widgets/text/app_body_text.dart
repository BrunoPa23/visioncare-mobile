import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visioncare_app/core/constants/app_colors.dart';
import 'package:visioncare_app/presentation/shared/viewmodel/text_scale_notifier.dart';

class AppBodyText extends ConsumerWidget{
 final String text;
 final TextAlign? textAlign;
 final Color? color;
 final double? size;

  const AppBodyText(
      this.text, {
      super.key,
      this.textAlign,
      this.color,
      this.size,
    });
  
    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final scale = ref.watch(textScaleProvider);
  
      return Text(
        text,
        textAlign: textAlign,
        style: GoogleFonts.openSans(
          textStyle: TextStyle(
            fontSize: (size ?? 20) * scale,
            fontWeight: FontWeight.normal,
            color: color ?? AppColors.textColor,
          ),
        )
      );
    } 
}