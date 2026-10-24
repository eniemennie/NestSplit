import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';

enum PillKind { lime, pink, blue, lightBlue, grey, navy, white }

/// Small rounded status label (Done, Overdue, Paid, Late...).
class StatusPill extends StatelessWidget {
  const StatusPill(this.label, {super.key, required this.kind});

  final String label;
  final PillKind kind;

  Color get _background {
    switch (kind) {
      case PillKind.lime:
        return AppColors.lime;
      case PillKind.pink:
        return AppColors.pink;
      case PillKind.blue:
        return AppColors.blue;
      case PillKind.lightBlue:
        return AppColors.todoBlue;
      case PillKind.grey:
        return AppColors.chipGrey;
      case PillKind.navy:
        return AppColors.navy;
      case PillKind.white:
        return AppColors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = kind == PillKind.navy ? AppColors.white : AppColors.navy;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: _background, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: AppText.pill.copyWith(color: textColor)),
    );
  }
}
