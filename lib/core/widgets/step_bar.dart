import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Three-step tracker (Reported / In progress / Fixed). Finished steps are lime,
/// the current step is blue and later steps are grey.
class StepBar extends StatelessWidget {
  const StepBar({super.key, required this.currentIndex, this.labels = const ['Reported', 'In progress', 'Fixed'], this.showLabels = true});

  final int currentIndex;
  final List<String> labels;
  final bool showLabels;

  Color _colorFor(int i) {
    if (i < currentIndex) return AppColors.lime;
    if (i == currentIndex) return AppColors.blue;
    return AppColors.chipGrey;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < labels.length; i++) ...[
              Expanded(
                child: Container(
                  height: 5,
                  decoration: BoxDecoration(color: _colorFor(i), borderRadius: BorderRadius.circular(3)),
                ),
              ),
              if (i < labels.length - 1) const SizedBox(width: 4),
            ],
          ],
        ),
        if (showLabels) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              for (var i = 0; i < labels.length; i++)
                Expanded(
                  child: Text(
                    labels[i],
                    textAlign: TextAlign.center,
                    style: AppText.caption.copyWith(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.navy),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
