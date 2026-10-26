import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// App name and tagline used on the splash and login screens.
class AppInfo {
  AppInfo._();
  static const String name = 'NestSplit';
  static const String tagline = 'Split the Bill, Share the Load.';

  /// Shown on the login screen and Profile so you can tell which build is installed.
  static const String version = '0.3.1 (blue splash)';
}

/// Simple static splash: the logo on the brand blue. It stays for [duration] and then calls
/// [onFinished]; the app fades to the login screen. No animation on purpose, so it looks the
/// same on every phone.
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.onFinished,
    this.duration = const Duration(milliseconds: 1800),
  });

  final VoidCallback onFinished;
  final Duration duration;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.duration, widget.onFinished);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Brand blue with the logo in the middle. The logo file has the same blue around it,
    // so it blends in with no visible edges.
    return const Scaffold(
      backgroundColor: AppColors.splashBlue,
      body: Center(
        child: Image(
          key: ValueKey('splash-logo'),
          image: AssetImage('assets/images/logo_foreground.png'),
          width: 260,
          height: 260,
        ),
      ),
    );
  }
}
