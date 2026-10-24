import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Rounded square holding an icon (chore icons, More-hub tiles, list leading icons).
class IconTile extends StatelessWidget {
  const IconTile({super.key, required this.icon, this.background = AppColors.background, this.iconColor = AppColors.navy, this.size = 40});

  final IconData icon;
  final Color background;
  final Color iconColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(size * 0.3)),
      child: Icon(icon, color: iconColor, size: size * 0.52),
    );
  }
}
