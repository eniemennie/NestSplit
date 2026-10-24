import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';

/// Page heading used on landlord screens: small caps line above a bold title.
class LandlordHeader extends StatelessWidget {
  const LandlordHeader({super.key, required this.overline, required this.title, this.trailing});

  final String overline;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(overline.toUpperCase(), style: AppText.overline),
              const SizedBox(height: 2),
              Text(title, style: AppText.screenTitle.copyWith(fontSize: 26)),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Scrolling page body with the standard landlord padding.
class LandlordPage extends StatelessWidget {
  const LandlordPage({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        children: children,
      ),
    );
  }
}

/// Back arrow row for pages opened from the landlord More hub.
class LandlordBackRow extends StatelessWidget {
  const LandlordBackRow({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: onBack,
        style: TextButton.styleFrom(foregroundColor: AppColors.navy, padding: EdgeInsets.zero),
        icon: const Icon(Icons.arrow_back_rounded, size: 18),
        label: const Text('More', style: AppText.caption),
      ),
    );
  }
}
