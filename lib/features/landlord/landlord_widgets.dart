import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../state/property_state.dart';

/// Page heading used on landlord screens: small caps line above a bold title.
class LandlordHeader extends StatelessWidget {
  const LandlordHeader({super.key, required this.overline, required this.title, this.trailing, this.onTitleTap});

  final String overline;
  final String title;
  final Widget? trailing;

  /// When set, the title becomes a button (used to switch boarding house).
  final VoidCallback? onTitleTap;

  @override
  Widget build(BuildContext context) {
    final titleText = Text(title, style: AppText.screenTitle.copyWith(fontSize: 26));
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(overline.toUpperCase(), style: AppText.overline),
              const SizedBox(height: 2),
              if (onTitleTap == null)
                titleText
              else
                InkWell(
                  onTap: onTitleTap,
                  child: Row(
                    children: [
                      Flexible(child: titleText),
                      const SizedBox(width: 4),
                      const Icon(Icons.unfold_more_rounded, color: AppColors.navy),
                    ],
                  ),
                ),
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

/// Bottom sheet to pick which boarding house the landlord screens show.
Future<void> showPropertyPicker(BuildContext context, PropertyState property) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (sheetContext) {
      final names = property.propertyNames;
      final counts = property.propertyRoomCounts;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your boarding houses', style: AppText.sectionTitle),
              const SizedBox(height: 10),
              for (var i = 0; i < names.length; i++)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    property.selectProperty(i);
                    Navigator.of(sheetContext).pop();
                  },
                  leading: const Icon(Icons.apartment_rounded, color: AppColors.navy),
                  title: Text(names[i], style: AppText.cardTitle),
                  subtitle: Text('${counts[i]} rooms', style: AppText.caption),
                  trailing: i == property.selectedIndex
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.navy)
                      : const Icon(Icons.radio_button_unchecked_rounded, color: AppColors.muted),
                ),
            ],
          ),
        ),
      );
    },
  );
}
