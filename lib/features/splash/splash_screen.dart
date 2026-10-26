import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/brand_logo.dart';

/// App name and tagline used on the splash and login screens.
class AppInfo {
  AppInfo._();
  static const String name = 'NestSplit';
  static const String tagline = 'Split the Bill, Share the Load.';
}

/// Shown for about two seconds when the app opens: logo, name and tagline on the brand blue.
/// It matches the native splash (same color and logo), so the hand-off looks seamless.
/// [onFinished] is called once when the animation ends.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logo;
  late final Animation<double> _text;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));
    _logo = CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.35, curve: Curves.easeOutBack));
    _text = CurvedAnimation(parent: _controller, curve: const Interval(0.25, 0.55, curve: Curves.easeOut));
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onFinished();
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBlue,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Opacity(
                  opacity: _logo.value.clamp(0.0, 1.0),
                  child: Transform.scale(scale: 0.8 + 0.2 * _logo.value, child: const BrandLogo(size: 150)),
                ),
                const SizedBox(height: 24),
                Opacity(
                  opacity: _text.value.clamp(0.0, 1.0),
                  child: Column(
                    children: [
                      Text(AppInfo.name, style: AppText.screenTitle.copyWith(fontSize: 38)),
                      const SizedBox(height: 6),
                      const Text(AppInfo.tagline, style: AppText.body),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
