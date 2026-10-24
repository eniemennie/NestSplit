import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Text styles used across the app. Change [fontFamily] once to restyle all text.
class AppText {
  AppText._();

  /// Set to the family name declared in pubspec.yaml to use the mockup font.
  static const String? fontFamily = null;

  static const TextStyle screenTitle = TextStyle(
      fontFamily: fontFamily, fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.navy, height: 1.1);
  static const TextStyle headerTitle = TextStyle(
      fontFamily: fontFamily, fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.navy);
  static const TextStyle sectionTitle = TextStyle(
      fontFamily: fontFamily, fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.navy);
  static const TextStyle cardTitle = TextStyle(
      fontFamily: fontFamily, fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.navy);
  static const TextStyle body = TextStyle(
      fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.navy);
  static const TextStyle bodyMuted = TextStyle(
      fontFamily: fontFamily, fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.muted);
  static const TextStyle caption = TextStyle(
      fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.muted);
  static const TextStyle overline = TextStyle(
      fontFamily: fontFamily, fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.muted, letterSpacing: 0.8);
  static const TextStyle button = TextStyle(
      fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.navy);
  static const TextStyle buttonLight = TextStyle(
      fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.white);
  static const TextStyle pill = TextStyle(
      fontFamily: fontFamily, fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.navy);
  static const TextStyle bigNumber = TextStyle(
      fontFamily: fontFamily, fontSize: 40, fontWeight: FontWeight.w800, color: AppColors.navy, height: 1.05);
}
