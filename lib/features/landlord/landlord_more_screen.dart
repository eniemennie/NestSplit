import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/icon_tile.dart';
import '../../core/widgets/ns_card.dart';
import '../../state/app_services.dart';
import 'landlord_widgets.dart';

/// Hub for the less frequent landlord tools, plus log out.
class LandlordMoreScreen extends StatelessWidget {
  const LandlordMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);
    Widget tile(IconData icon, Color color, String title, String sub, int page) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: NsCard(
          onTap: () => services.landlordMorePage.value = page,
          child: Row(
            children: [
              IconTile(icon: icon, background: color, size: 44),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppText.cardTitle),
                    const SizedBox(height: 2),
                    Text(sub, style: AppText.caption),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.navy),
            ],
          ),
        ),
      );
    }

    return LandlordPage(
      children: [
        const LandlordHeader(overline: 'Landlord view', title: 'More'),
        const SizedBox(height: 16),
        tile(Icons.build_rounded, AppColors.pink, 'Maintenance', 'Repair requests and status', 1),
        tile(Icons.campaign_rounded, AppColors.blue, 'Announcements', 'Send notices to tenants', 2),
        tile(Icons.rule_rounded, AppColors.lime, 'Rule templates', 'Share house rules and see who accepted', 3),
        const SizedBox(height: 6),
        OutlinedButton.icon(
          onPressed: services.signOut,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.navy,
            side: const BorderSide(color: AppColors.navy, width: 1.4),
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          icon: const Icon(Icons.logout_rounded, size: 18),
          label: const Text('Log out'),
        ),
      ],
    );
  }
}
