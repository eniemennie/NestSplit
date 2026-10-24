import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/icon_tile.dart';
import '../../core/widgets/ns_card.dart';
import '../../state/app_services.dart';
import '../chores/add_chore_screen.dart';
import '../chores/chore_detail_screen.dart';
import '../members/members_screen.dart';
import '../quick_split/quick_split_screen.dart';
import '../recap/recap_screen.dart';
import '../rules/house_rules_screen.dart';
import '../swaps/swaps_screen.dart';

/// Screen 6: hub that links to the extra screens.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final household = AppScope.of(context).household;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        children: [
          const Text('More', style: AppText.screenTitle),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _HubTile(
                  icon: Icons.check_rounded,
                  color: AppColors.blue,
                  label: 'Chore detail',
                  onTap: () {
                    final open = household.myOpenChores;
                    final chore = open.isNotEmpty ? open.first : household.chores.first;
                    _open(context, ChoreDetailScreen(choreId: chore.id));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HubTile(
                  icon: Icons.sync_rounded,
                  color: AppColors.pink,
                  label: 'Add & rotate',
                  onTap: () => _open(context, const AddChoreScreen()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _HubTile(
                  icon: Icons.swap_horiz_rounded,
                  color: AppColors.lime,
                  label: 'Swap requests',
                  onTap: () => _open(context, const SwapsScreen()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HubTile(
                  icon: Icons.calendar_today_rounded,
                  color: AppColors.blue,
                  label: 'Weekly recap',
                  onTap: () => _open(context, const RecapScreen()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _HubTile(
                  icon: Icons.receipt_long_rounded,
                  color: AppColors.pink,
                  label: 'House rules',
                  onTap: () => _open(context, const HouseRulesScreen()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HubTile(
                  icon: Icons.groups_rounded,
                  color: AppColors.lime,
                  label: 'Members',
                  onTap: () => _open(context, const MembersScreen()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          NsCard(
            onTap: () => _open(context, const QuickSplitScreen()),
            child: Row(
              children: [
                const IconTile(icon: Icons.request_quote_rounded, background: AppColors.navy, iconColor: AppColors.white),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quick Split', style: AppText.cardTitle),
                      SizedBox(height: 2),
                      Text('Share a bill in seconds', style: AppText.caption),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.navy),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HubTile extends StatelessWidget {
  const _HubTile({required this.icon, required this.color, required this.label, required this.onTap});

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return NsCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: SizedBox(
        height: 88,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconTile(icon: icon, background: color, size: 38),
            Text(label, style: AppText.cardTitle),
          ],
        ),
      ),
    );
  }
}
