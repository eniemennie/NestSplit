import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/time_format.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/member_avatar.dart';
import '../../core/widgets/ns_card.dart';
import '../../core/widgets/ns_header.dart';
import '../../core/widgets/segmented_bar.dart';
import '../../core/widgets/snack.dart';
import '../../state/app_services.dart';

/// Screen 10: the week in numbers, with a neutral "talk it out" tip.
class RecapScreen extends StatelessWidget {
  const RecapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final household = AppScope.of(context).household;
    return ListenableBuilder(
      listenable: household,
      builder: (context, _) {
        final week = TimeFormat.isoWeek(DateTime.now());
        final top = household.topContributor;
        final total = household.totalChoresThisWeek;
        final done = household.totalDone;
        final balanced = household.fairnessScore >= 80;
        final tip = balanced
            ? 'Great balance this week. Keep the rotation going.'
            : "Shares were uneven this week. A quick chat about next week's rotation could help everyone.";
        return SubPage(
          title: 'Week $week recap',
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Container(
                color: AppColors.navy,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Expanded(child: SizedBox(height: 7, child: ColoredBox(color: AppColors.blue))),
                        Expanded(child: SizedBox(height: 7, child: ColoredBox(color: AppColors.pink))),
                        Expanded(child: SizedBox(height: 7, child: ColoredBox(color: AppColors.lime))),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(household.householdName, style: const TextStyle(color: AppColors.lime, fontWeight: FontWeight.w700, fontSize: 13)),
                          const SizedBox(height: 8),
                          Text('$total chores,\n$done done', style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w800, fontSize: 30, height: 1.1)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (top != null)
              NsCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    MemberAvatar(member: top, size: 38),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Top contributor', style: AppText.caption),
                          Text('${top.name} · ${household.doneThisWeek[top.id] ?? 0} chores', style: AppText.sectionTitle.copyWith(fontSize: 16)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            NsCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Shares this week', style: AppText.cardTitle),
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
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.infoBlue, borderRadius: BorderRadius.circular(14)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.chat_bubble_rounded, color: AppColors.navy, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Talk it out', style: AppText.cardTitle),
                        const SizedBox(height: 3),
                        Text(tip, style: AppText.body.copyWith(fontSize: 13, color: AppColors.muted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Share recap',
              icon: Icons.share_outlined,
              onPressed: () async {
                final text = 'NestSplit recap, ${household.householdName}, week $week: $done of $total chores done.'
                    '${top == null ? '' : ' Top contributor: ${top.name}.'}';
                await Clipboard.setData(ClipboardData(text: text));
                if (!context.mounted) return;
                showNsSnack(context, 'Recap copied. Paste it in your group chat.');
              },
            ),
          ],
        );
      },
    );
  }
}
