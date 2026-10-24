import 'package:flutter/material.dart';

/// The NestSplit logo, loaded from assets/images/logo.png.
/// To change the logo, replace that file (keep it square) and run `flutter run` again.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 120});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: Image.asset(
        'assets/images/logo.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        semanticLabel: 'NestSplit logo',
      ),
    );
  }
}
