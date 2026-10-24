import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Shows a short navy message at the bottom of the screen.
void showNsSnack(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(message, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w600)),
      backgroundColor: AppColors.navy,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
