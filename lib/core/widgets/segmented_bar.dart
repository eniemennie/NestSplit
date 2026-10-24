import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// One colored part of a [SegmentedBar]. [weight] is relative to the others.
class BarSegment {
  const BarSegment(this.color, this.weight);
  final Color color;
  final double weight;
}

/// Horizontal bar made of colored segments, e.g. each roommate's share of chores.
class SegmentedBar extends StatelessWidget {
  const SegmentedBar({super.key, required this.segments, this.height = 12, this.trackColor = AppColors.chipGrey});

  final List<BarSegment> segments;
  final double height;
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    final visible = segments.where((s) => s.weight > 0).toList();
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: SizedBox(
        height: height,
        child: visible.isEmpty
            ? ColoredBox(color: trackColor, child: const SizedBox.expand())
            : Row(
                children: [
                  for (final s in visible)
                    Expanded(
                      flex: (s.weight * 1000).round().clamp(1, 1000000),
                      child: ColoredBox(color: s.color, child: const SizedBox.expand()),
                    ),
                ],
              ),
      ),
    );
  }
}
