import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// The NestSplit house mark drawn in code (faceted house + two sparkles).
/// Replace with Image.asset('assets/logo.png') if you prefer the exported logo file.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 120});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: _LogoPainter());
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 100;
    Offset p(double x, double y) => Offset(x * s, y * s);
    Path poly(List<Offset> pts) {
      final path = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (final o in pts.skip(1)) {
        path.lineTo(o.dx, o.dy);
      }
      return path..close();
    }

    final blue = Paint()..color = AppColors.blue;
    final pink = Paint()..color = AppColors.pink;
    final lime = Paint()..color = AppColors.lime;

    // Right wall (lime), left half of house (blue), right roof (pink), door (pink).
    canvas.drawPath(poly([p(50, 48), p(92, 48), p(92, 94), p(50, 94)]), lime);
    canvas.drawPath(poly([p(50, 10), p(8, 50), p(8, 94), p(50, 94)]), blue);
    canvas.drawPath(poly([p(50, 10), p(92, 48), p(50, 48)]), pink);
    canvas.drawPath(poly([p(34, 66), p(54, 66), p(54, 94), p(34, 94)]), pink);

    _star(canvas, p(74, 14), 9 * s, 4 * s, AppColors.lime, true);
    _star(canvas, p(88, 24), 4.5 * s, 2.2 * s, AppColors.navy, false);
  }

  void _star(Canvas canvas, Offset c, double outer, double inner, Color color, bool outline) {
    const points = 8;
    final path = Path();
    for (var i = 0; i < points * 2; i++) {
      final r = i.isEven ? outer : inner;
      final angle = -math.pi / 2 + i * math.pi / points;
      final o = Offset(c.dx + r * math.cos(angle), c.dy + r * math.sin(angle));
      if (i == 0) {
        path.moveTo(o.dx, o.dy);
      } else {
        path.lineTo(o.dx, o.dy);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
    if (outline) {
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = AppColors.navy,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
