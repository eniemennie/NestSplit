import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/brand_logo.dart';

/// App name and tagline used on the splash and login screens.
class AppInfo {
  AppInfo._();
  static const String name = 'NestSplit';
  static const String tagline = 'Split the Bill, Share the Load.';

  /// Shown on the login screen and Profile so you can tell which build is installed.
  static const String version = '0.3.0 (static splash)';
}

/// Simple static splash: logo, name, brand band and tagline on the app's off-white background.
/// It stays for [duration] and then calls [onFinished]; the app fades to the login screen.
/// There is no animation here on purpose, so it always shows the same way on every phone.
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Same decoration as the login screen, so the two feel like one flow.
          const Positioned(left: 24, top: 70, child: _Triangle()),
          Positioned(
            right: 52,
            top: 96,
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(color: AppColors.pink, shape: BoxShape.circle),
            ),
          ),
          Positioned(
            right: 28,
            bottom: 140,
            child: Transform.rotate(
              angle: -0.14,
              child: Container(width: 100, height: 34, color: AppColors.lime),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 5),
                const BrandLogo(size: 140),
                const SizedBox(height: 24),
                Text(
                  AppInfo.name,
                  style: AppText.screenTitle.copyWith(fontSize: 40, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                ),
                const SizedBox(height: 12),
                const _TriBand(),
                const SizedBox(height: 14),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(AppInfo.tagline, textAlign: TextAlign.center, style: AppText.bodyMuted),
                ),
                const Spacer(flex: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The blue / pink / lime band used on the app's buttons.
class _TriBand extends StatelessWidget {
  const _TriBand();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: const SizedBox(
        width: 96,
        height: 6,
        child: Row(
          children: [
            Expanded(child: ColoredBox(color: AppColors.blue, child: SizedBox.expand())),
            Expanded(child: ColoredBox(color: AppColors.pink, child: SizedBox.expand())),
            Expanded(child: ColoredBox(color: AppColors.lime, child: SizedBox.expand())),
          ],
        ),
      ),
    );
  }
}

class _Triangle extends StatelessWidget {
  const _Triangle();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(46, 44), painter: _TrianglePainter());
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(0, size.height * 0.62)
      ..lineTo(size.width * 0.85, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = AppColors.blue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
