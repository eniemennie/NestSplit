import 'package:flutter/material.dart';
import '../../core/widgets/brand_logo.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/member_avatar.dart';
import '../../core/widgets/ns_card.dart';
import '../../core/widgets/progress_ring.dart';
import '../../core/widgets/segmented_bar.dart';
import '../../data/models/chore.dart';
import '../../state/app_services.dart';
import '../activity/activity_screen.dart';
import '../chores/chore_detail_screen.dart';
import '../chores/chore_icons.dart';
import '../chores/chore_row.dart';

/// Screen 2: this week's progress, the user's chores today and the household share.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);
    final household = services.household;
    return SafeArea(
      child: ListenableBuilder(
        listenable: household,
        builder: (context, _) {
          final user = household.currentUser;
          final myChores = household.myOpenChores;
          Chore? overdue;
          for (final c in myChores) {
            if (c.status == ChoreStatus.overdue) {
              overdue = c;
              break;
            }
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            children: [
              Row(
                children: [
                  const BrandLogo(size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(household.householdName, style: AppText.caption),
                        const SizedBox(height: 2),
                        Text('Hi, ${user.name}', style: AppText.screenTitle),
                      ],
                    ),
                  ),
                  SquareIconButton(
                    icon: Icons.notifications_none_rounded,
                    showDot: true,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const ActivityScreen()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  MemberAvatar(member: user, size: 42, radius: 12),
                ],
              ),
              const SizedBox(height: 18),
              NsCard(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    ProgressRing(done: household.choresDone, total: household.chores.length, size: 108),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('This week', style: AppText.caption),
                          const SizedBox(height: 2),
                          Text('${household.choresLeft} left to go', style: AppText.sectionTitle.copyWith(fontSize: 21)),
                          const SizedBox(height: 4),
                          Text('Nice pace, ${household.householdName}.', style: AppText.caption),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (overdue != null) ...[
                const SizedBox(height: 14),
                _NudgeCard(chore: overdue),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  const Expanded(child: Text('Your chores today', style: AppText.sectionTitle)),
                  GestureDetector(
                    onTap: () => services.tenantTab.value = 1,
                    child: const Text('See all', style: AppText.caption),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (myChores.isEmpty)
                const NsCard(child: Text('Nothing left for you today. Nice work!', style: AppText.bodyMuted))
              else
                for (final chore in myChores) ...[
                  ChoreRow(
                    chore: chore,
                    assignee: household.memberById(chore.assigneeId),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => ChoreDetailScreen(choreId: chore.id)),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              const SizedBox(height: 4),
              NsCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(child: Text('Household share', style: AppText.caption)),
                        Text('Your share: ${household.sharePercent(user.id)}%', style: AppText.cardTitle.copyWith(fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SegmentedBar(
                      segments: [
                        for (final m in household.members)
                          BarSegment(memberColor(m.color), (household.doneThisWeek[m.id] ?? 0).toDouble()),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NudgeCard extends StatelessWidget {
  const _NudgeCard({required this.chore});

  final Chore chore;

  @override
  Widget build(BuildContext context) {
    return NsCard(
      color: AppColors.pink,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(choreIcon(chore.iconKey), size: 28, color: AppColors.navy),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${chore.name} is a day behind', style: AppText.cardTitle.copyWith(fontSize: 14)),
                const SizedBox(height: 2),
                const Text('Got a moment today? Or ask for a swap.', style: AppText.caption),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => ChoreDetailScreen(choreId: chore.id)),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(12)),
              child: const Text('Do it', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w800, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}
