import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Custom toggle: navy track with a lime knob when on (as in the mockup).
class NsSwitch extends StatelessWidget {
  const NsSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 50,
        height: 28,
        padding: const EdgeInsets.all(3),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        decoration: BoxDecoration(
          color: value ? AppColors.navy : AppColors.chipGrey,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: value ? AppColors.lime : AppColors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
