import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text.dart';

/// App-wide [ThemeData]. Individual widgets in core/widgets do their own styling
/// so the look stays identical to the mockup rather than Material defaults.
class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.blue,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: AppText.fontFamily,
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.navy,
        displayColor: AppColors.navy,
      ),
      splashFactory: InkRipple.splashFactory,
    );
  }
}
