import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';

/// App name and tagline used on the splash and login screens.
class AppInfo {
  AppInfo._();
  static const String name = 'NestSplit';
  static const String tagline = 'Split the Bill, Share the Load.';
}

/// Launch animation (about 3.4 s), in this order:
///  1. soft brand shapes drift in behind,
///  2. the house builds itself piece by piece (roof, walls, door, sparkles) and settles,
///  3. "NestSplit" is revealed left to right,
///  4. the blue / pink / lime band grows under the name,
///  5. the tagline fades up.
/// [onFinished] is called once at the end; the app then cross-fades to the next screen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  static const double _totalSeconds = 3.4;

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 3400));
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

  /// 0..1 progress of a step that starts at [delay] seconds and lasts [duration], eased by [curve].
  double _step(double seconds, double delay, double duration, [Curve curve = Curves.easeOutCubic]) {
    return curve.transform(((seconds - delay) / duration).clamp(0.0, 1.0));
  }

  Widget _shape(double seconds, double delay, Alignment alignment, Widget shape) {
    final e = _step(seconds, delay, 0.9);
    final drift = math.sin(seconds * 1.4 + delay * 5) * 4;
    return Align(
      alignment: alignment,
      child: Opacity(
        opacity: e * 0.9,
        child: Transform.translate(
          offset: Offset(0, (1 - e) * 24 + drift),
          child: Transform.scale(scale: 0.6 + 0.4 * e, child: shape),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final seconds = _controller.value * _totalSeconds;

          // The house pulses very slightly once it is built.
          final settle = _step(seconds, 1.55, 0.6, Curves.linear);
          final houseScale = 1 + 0.045 * math.sin(math.pi * settle);

          final nameReveal = _step(seconds, 1.25, 0.8);
          final band = _step(seconds, 1.95, 0.6, Curves.easeOutBack);
          final tagline = _step(seconds, 2.3, 0.6);

          return Stack(
            children: [
              // Soft decoration, same shapes as the login screen.
              _shape(seconds, 0.0, const Alignment(-0.82, -0.72), const _Triangle()),
              _shape(
                seconds,
                0.15,
                const Alignment(0.8, -0.55),
                Container(width: 30, height: 30, decoration: const BoxDecoration(color: AppColors.pink, shape: BoxShape.circle)),
              ),
              _shape(
                seconds,
                0.3,
                const Alignment(0.78, 0.72),
                Transform.rotate(angle: 0.17, child: Container(width: 84, height: 28, color: AppColors.lime)),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.scale(
                      scale: houseScale,
                      child: CustomPaint(size: const Size(150, 150 * 110 / 120), painter: _HousePainter(seconds)),
                    ),
                    const SizedBox(height: 14),
                    // Name: revealed left to right while sliding up.
                    Opacity(
                      opacity: nameReveal,
                      child: Transform.translate(
                        offset: Offset(0, 12 * (1 - nameReveal)),
                        child: ShaderMask(
                          blendMode: BlendMode.dstIn,
                          shaderCallback: (rect) => LinearGradient(
                            colors: const [Colors.white, Colors.white, Colors.transparent],
                            stops: [0, (nameReveal * 1.35 - 0.35).clamp(0.0, 1.0), (nameReveal * 1.35).clamp(0.0, 1.0)],
                          ).createShader(rect),
                          child: Text(
                            AppInfo.name,
                            style: AppText.screenTitle.copyWith(fontSize: 40, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // The blue / pink / lime band from the buttons, growing from the middle.
                    Transform.scale(
                      scaleX: band.clamp(0.0, 1.2),
                      child: Opacity(
                        opacity: band.clamp(0.0, 1.0),
                        child: const _TriBand(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Opacity(
                      opacity: tagline,
                      child: Transform.translate(
                        offset: Offset(0, 10 * (1 - tagline)),
                        child: const Text(AppInfo.tagline, style: AppText.bodyMuted),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TriBand extends StatelessWidget {
  const _TriBand();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: SizedBox(
        width: 96,
        height: 6,
        child: Row(
          children: const [
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

/// Draws the NestSplit house in the prototype's 120 x 110 box, animating each piece in turn.
class _HousePainter extends CustomPainter {
  _HousePainter(this.seconds);

  final double seconds;

  static const Cubic _overshoot = Cubic(0.2, 0.9, 0.3, 1.25);
  static const Cubic _overshootSoft = Cubic(0.2, 0.9, 0.3, 1.2);
  static const Cubic _overshootBig = Cubic(0.2, 0.9, 0.3, 1.4);
  static const Cubic _overshootSpin = Cubic(0.2, 0.9, 0.3, 1.3);

  /// Draws one piece with an entrance animation: [from] offset, rotation (radians) and scale
  /// ease to rest between [delay] and [delay] + [duration].
  void _piece(
    Canvas canvas,
    Offset center, {
    required double delay,
    required double duration,
    required Curve curve,
    Offset fromOffset = Offset.zero,
    double fromRotation = 0,
    double fromScale = 1,
    required void Function(double opacity) draw,
  }) {
    final p = ((seconds - delay) / duration).clamp(0.0, 1.0);
    if (p <= 0) return;
    final e = curve.transform(p);
    canvas.save();
    canvas.translate(center.dx + fromOffset.dx * (1 - e), center.dy + fromOffset.dy * (1 - e));
    canvas.rotate(fromRotation * (1 - e));
    final s = fromScale + (1 - fromScale) * e;
    canvas.scale(s, s);
    canvas.translate(-center.dx, -center.dy);
    draw(e.clamp(0.0, 1.0));
    canvas.restore();
  }

  Path _star(double cx, double cy, double outer, double inner, int n) {
    final path = Path();
    for (var i = 0; i < n * 2; i++) {
      final a = math.pi * i / n - math.pi / 2;
      final r = i.isOdd ? inner : outer;
      final x = cx + r * math.cos(a);
      final y = cy + r * math.sin(a);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    return path..close();
  }

  Paint _paint(Color color, double opacity) => Paint()..color = color.withAlpha((opacity.clamp(0.0, 1.0) * 255).round());

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 120;
    canvas.scale(s, s);

    // Roof, left (blue) and right (pink).
    _piece(canvas, const Offset(33, 33),
        delay: 0.1, duration: 0.55, curve: _overshoot, fromOffset: const Offset(-46, -10), fromRotation: -14 * math.pi / 180,
        draw: (o) => canvas.drawPath(
            Path()..moveTo(8, 54)..lineTo(58, 12)..lineTo(58, 54)..close(), _paint(AppColors.blue, o)));
    _piece(canvas, const Offset(83, 33),
        delay: 0.25, duration: 0.55, curve: _overshoot, fromOffset: const Offset(46, -10), fromRotation: 14 * math.pi / 180,
        draw: (o) => canvas.drawPath(
            Path()..moveTo(58, 12)..lineTo(108, 54)..lineTo(58, 54)..close(), _paint(AppColors.pink, o)));
    // Walls, left (blue) and right (lime).
    _piece(canvas, const Offset(37, 79),
        delay: 0.45, duration: 0.5, curve: _overshootSoft, fromOffset: const Offset(0, 44),
        draw: (o) => canvas.drawRect(const Rect.fromLTWH(16, 54, 42, 50), _paint(AppColors.blue, o)));
    _piece(canvas, const Offset(79, 79),
        delay: 0.58, duration: 0.5, curve: _overshootSoft, fromOffset: const Offset(0, 44),
        draw: (o) => canvas.drawRect(const Rect.fromLTWH(58, 54, 42, 50), _paint(AppColors.lime, o)));
    // Door.
    _piece(canvas, const Offset(58, 86),
        delay: 0.8, duration: 0.45, curve: _overshootBig, fromScale: 0,
        draw: (o) => canvas.drawRect(const Rect.fromLTWH(46, 68, 24, 36), _paint(AppColors.pink, o)));
    // Big sparkle with a lime center.
    _piece(canvas, const Offset(92, 16),
        delay: 0.95, duration: 0.6, curve: _overshootSpin, fromRotation: -200 * math.pi / 180, fromScale: 0,
        draw: (o) {
          canvas.drawPath(_star(92, 16, 14, 6, 8), _paint(AppColors.navy, o));
          canvas.drawCircle(const Offset(92, 16), 4, _paint(AppColors.lime, o));
        });
    // Small sparkle.
    _piece(canvas, const Offset(110, 36),
        delay: 1.1, duration: 0.5, curve: _overshootSpin, fromRotation: -200 * math.pi / 180, fromScale: 0,
        draw: (o) => canvas.drawPath(_star(110, 36, 8, 3.5, 8), _paint(AppColors.navy, o)));
  }

  @override
  bool shouldRepaint(covariant _HousePainter oldDelegate) => oldDelegate.seconds != seconds;
}
