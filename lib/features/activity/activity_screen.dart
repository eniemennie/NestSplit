import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/dashed_box.dart';
import '../../core/widgets/member_avatar.dart';
import '../../core/widgets/ns_card.dart';
import '../../core/widgets/ns_header.dart';
import '../../core/widgets/snack.dart';
import '../../data/models/activity_item.dart';
import '../../state/app_services.dart';

/// Screen 5: household activity feed (opened from the bell on Home).
class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final household = AppScope.of(context).household;
    return ListenableBuilder(
      listenable: household,
      builder: (context, _) {
        final today = household.activity.where((a) => a.isToday).toList();
        final earlier = household.activity.where((a) => !a.isToday).toList();
        return SubPage(
          title: 'Activity',
          trailing: GestureDetector(
            onTap: () => showNsSnack(context, 'All caught up.'),
            child: const Text('Mark read', style: AppText.caption),
          ),
          children: [
            if (today.isNotEmpty) ...[
              const Text('TODAY', style: AppText.overline),
              const SizedBox(height: 8),
              for (final item in today) _ActivityRow(item: item),
              const SizedBox(height: 10),
            ],
            if (earlier.isNotEmpty) ...[
              const Text('EARLIER', style: AppText.overline),
              const SizedBox(height: 8),
              for (final item in earlier) _ActivityRow(item: item),
              const SizedBox(height: 10),
            ],
            // Shown at the end of the feed (the mockup shows it as the empty state).
            const DashedBox(
              padding: EdgeInsets.symmetric(vertical: 22, horizontal: 16),
              child: Column(
                children: [
                  Icon(Icons.notifications_off_outlined, color: AppColors.blue, size: 26),
                  SizedBox(height: 8),
                  Text('All quiet at home', style: AppText.cardTitle),
                  SizedBox(height: 2),
                  Text('New activity shows up here.', style: AppText.caption),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.item});

  final ActivityItem item;

  @override
  Widget build(BuildContext context) {
    final household = AppScope.of(context).household;
    final member = household.memberById(item.memberId);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: NsCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        radius: 12,
        child: Row(
          children: [
            MemberAvatar(member: member, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: '${member.name} ', style: AppText.cardTitle.copyWith(fontSize: 13.5)),
                    TextSpan(text: item.message, style: AppText.body.copyWith(fontSize: 13.5, color: AppColors.linkBlue)),
                  ],
                ),
              ),
            ),
            Text(item.timeLabel, style: AppText.caption),
          ],
        ),
      ),
    );
  }
}
