import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/time_format.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/dashed_box.dart';
import '../../core/widgets/member_avatar.dart';
import '../../core/widgets/ns_card.dart';
import '../../core/widgets/ns_header.dart';
import '../../core/widgets/snack.dart';
import '../../core/widgets/status_pill.dart';
import '../../data/models/chore.dart';
import '../../state/app_services.dart';
import 'chore_icons.dart';

/// Screen 7: one chore, with the big "Mark as done" button and the completed state.
class ChoreDetailScreen extends StatelessWidget {
  const ChoreDetailScreen({super.key, required this.choreId});

  final String choreId;

  @override
  Widget build(BuildContext context) {
    final household = AppScope.of(context).household;
    return ListenableBuilder(
      listenable: household,
      builder: (context, _) {
        final chore = household.choreById(choreId);
        if (chore == null) {
          return const SubPage(title: 'Chore', children: [Text('This chore no longer exists.', style: AppText.bodyMuted)]);
        }
        final assignee = household.memberById(chore.assigneeId);
        return SubPage(
          title: chore.name,
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(color: AppColors.lime, borderRadius: BorderRadius.circular(18)),
              child: Icon(choreIcon(chore.iconKey), size: 64, color: AppColors.navy),
            ),
            const SizedBox(height: 14),
            NsCard(
              child: Column(
                children: [
                  _InfoRow(
                    label: 'Assigned to',
                    value: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MemberAvatar(member: assignee, size: 24),
                        const SizedBox(width: 8),
                        Text(assignee.name, style: AppText.cardTitle),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(label: 'Due', value: Text(chore.dueFull, style: AppText.cardTitle)),
                  const SizedBox(height: 12),
                  _InfoRow(label: 'Difficulty', value: StatusPill(_difficultyLabel(chore.difficulty), kind: PillKind.blue)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            DashedBox(
              onTap: () => showNsSnack(context, 'Photo upload is not connected yet.'),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_camera_outlined, size: 18, color: AppColors.muted),
                  SizedBox(width: 8),
                  Text('Add a photo (optional)', style: AppText.bodyMuted),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (!chore.isDone)
              TriBandButton(
                label: 'Mark as done',
                onPressed: () {
                  household.markChoreDone(chore.id);
                  showNsSnack(context, 'Nice work, ${assignee.name}!');
                },
              )
            else
              _DoneBanner(assigneeName: assignee.name, completedAt: chore.completedAt),
          ],
        );
      },
    );
  }

  static String _difficultyLabel(Difficulty d) {
    switch (d) {
      case Difficulty.light:
        return 'Light';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.heavy:
        return 'Heavy';
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: AppText.bodyMuted)),
        value,
      ],
    );
  }
}

class _DoneBanner extends StatelessWidget {
  const _DoneBanner({required this.assigneeName, required this.completedAt});

  final String assigneeName;
  final DateTime? completedAt;

  @override
  Widget build(BuildContext context) {
    final when = completedAt == null ? 'Completed' : 'Completed · ${TimeFormat.dayAndTime(completedAt!)}';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(color: AppColors.lime, shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded, color: AppColors.navy),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Done! Thanks, $assigneeName', style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 2),
                Text(when, style: const TextStyle(color: AppColors.lime, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
