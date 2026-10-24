import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Solid navy button (primary action).
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 54,
    this.color = AppColors.navy,
    this.textColor = AppColors.white,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: textColor, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(label, style: AppText.button.copyWith(color: textColor)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// White button with a navy outline and the blue/pink/lime band on its left edge.
/// This is the recurring "logo motif" button from the mockup.
class TriBandButton extends StatelessWidget {
  const TriBandButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 54,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(14);
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Material(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: const BorderSide(color: AppColors.navy, width: 1.6),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Row(
            children: [
              SizedBox(
                width: 44,
                child: Column(
                  children: const [
                    Expanded(child: ColoredBox(color: AppColors.blue, child: SizedBox.expand())),
                    Expanded(child: ColoredBox(color: AppColors.pink, child: SizedBox.expand())),
                    Expanded(child: ColoredBox(color: AppColors.lime, child: SizedBox.expand())),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: AppColors.navy, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(label, style: AppText.button),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small square icon button (back, add, calendar...).
class SquareIconButton extends StatelessWidget {
  const SquareIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.background = AppColors.white,
    this.iconColor = AppColors.navy,
    this.size = 42,
    this.showDot = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Color background;
  final Color iconColor;
  final double size;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Material(
              color: background,
              borderRadius: BorderRadius.circular(12),
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onPressed,
                child: Icon(icon, color: iconColor, size: 22),
              ),
            ),
          ),
          if (showDot)
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(color: AppColors.pink, shape: BoxShape.circle),
              ),
            ),
        ],
      ),
    );
  }
}
