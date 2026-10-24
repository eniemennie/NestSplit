import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/member_avatar.dart';
import '../../core/widgets/ns_card.dart';
import '../../data/models/member.dart';
import '../../state/app_services.dart';

/// Screen 4: fairness score, chores done per roommate, streak and "who did what".
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final household = AppScope.of(context).household;
    return SafeArea(
      child: ListenableBuilder(
        listenable: household,
        builder: (context, _) {
          final maxDone = household.members
              .map((m) => household.doneThisWeek[m.id] ?? 0)
              .fold<int>(1, (a, b) => b > a ? b : a);

          Member? streakMember;
          var bestStreak = 0;
          for (final m in household.members) {
            final weeks = household.streakWeeks[m.id] ?? 0;
            if (weeks > bestStreak) {
              bestStreak = weeks;
              streakMember = m;
            }
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            children: [
              const Text('Progress', style: AppText.screenTitle),
              const SizedBox(height: 14),
              NsCard(
                child: Row(
                  children: [
                    Container(
                      width: 66,
                      height: 66,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: AppColors.blue, borderRadius: BorderRadius.circular(14)),
                      child: Text('${household.fairnessScore}', style: AppText.screenTitle.copyWith(fontSize: 30)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Fairness score', style: AppText.caption),
                          const SizedBox(height: 2),
                          Text(household.fairnessLabel, style: AppText.sectionTitle.copyWith(fontSize: 17)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              NsCard(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Chores done this week', style: AppText.cardTitle.copyWith(fontSize: 14.5)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 200,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          for (final m in household.members)
                            _Bar(
                              member: m,
                              count: household.doneThisWeek[m.id] ?? 0,
                              maxCount: maxDone,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (streakMember != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department_rounded, color: AppColors.lime, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        '${streakMember.name} · $bestStreak-week streak',
                        style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              const Text('Who did what', style: AppText.sectionTitle),
              const SizedBox(height: 12),
              for (final m in household.members)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    children: [
                      MemberAvatar(member: m, size: 30),
                      const SizedBox(width: 12),
                      Expanded(child: Text(m.name, style: AppText.cardTitle)),
                      Text('Share this week: ${household.sharePercent(m.id)}%', style: AppText.caption),
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

class _Bar extends StatelessWidget {
  const _Bar({required this.member, required this.count, required this.maxCount});

  final Member member;
  final int count;
  final int maxCount;

  @override
  Widget build(BuildContext context) {
    const maxHeight = 130.0;
    final height = count == 0 ? 6.0 : (maxHeight * count / maxCount).clamp(6.0, maxHeight).toDouble();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$count', style: AppText.caption.copyWith(color: AppColors.navy, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Container(
          width: 46,
          height: height,
          decoration: BoxDecoration(
            color: memberColor(member.color),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
        ),
        const SizedBox(height: 8),
        MemberAvatar(member: member, size: 26),
      ],
    );
  }
}
