//Icon Button, params: icon, onPressed, size?, color?
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visioncare_app/core/constants/app_colors.dart';
import 'package:visioncare_app/presentation/shared/viewmodel/text_scale_notifier.dart';

class AppIconButton extends ConsumerWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double? size;
  final Color? color;
  final Color? backgroundColor;
  final double? roundedRadius;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size,
    this.color,
    this.backgroundColor,
    this.roundedRadius,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scale = ref.watch(textScaleProvider);
    
    return IconButton(
      icon: Icon(icon, size: (size ?? 30)*scale , color: color ?? Colors.black),
      onPressed: onPressed,
      style: IconButton.styleFrom(
        padding: EdgeInsets.all(20),
        backgroundColor: backgroundColor ?? AppColors.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(roundedRadius ?? (size ?? 30)),
        ),
      ),
    );
  }
}