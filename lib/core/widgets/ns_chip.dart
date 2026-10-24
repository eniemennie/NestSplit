import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Selectable pill used for filters and option pickers.
/// Selected = navy fill with white text, otherwise white.
class NsChip extends StatelessWidget {
  const NsChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
    this.outlineWhenSelected = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// Optional fill used when not selected (e.g. lime for "Light").
  final Color? color;

  /// Use a navy outline instead of a navy fill when selected (difficulty chips).
  final bool outlineWhenSelected;

  @override
  Widget build(BuildContext context) {
    final bool filled = selected && !outlineWhenSelected;
    final Color bg = filled ? AppColors.navy : (color ?? AppColors.white);
    final Color fg = filled ? AppColors.white : AppColors.navy;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: selected && outlineWhenSelected ? Border.all(color: AppColors.navy, width: 1.6) : null,
        ),
        child: Text(label, style: AppText.pill.copyWith(color: fg, fontSize: 12.5)),
      ),
    );
  }
}
