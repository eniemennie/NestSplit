import 'package:flutter/material.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/icon_tile.dart';
import '../../core/widgets/member_avatar.dart';
import '../../core/widgets/ns_card.dart';
import '../../core/widgets/status_pill.dart';
import '../../data/models/chore.dart';
import '../../data/models/member.dart';
import 'chore_icons.dart';

/// One chore in a list: icon, name, who and when, avatar and status pill.
class ChoreRow extends StatelessWidget {
  const ChoreRow({super.key, required this.chore, required this.assignee, required this.onTap});

  final Chore chore;
  final Member assignee;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return NsCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      radius: 14,
      onTap: onTap,
      child: Row(
        children: [
          IconTile(icon: choreIcon(chore.iconKey), size: 38),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(chore.name, style: AppText.cardTitle.copyWith(fontSize: 14.5), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('${assignee.name} · ${chore.day}', style: AppText.caption),
              ],
            ),
          ),
          const SizedBox(width: 8),
          MemberAvatar(member: assignee, size: 26),
          const SizedBox(width: 8),
          statusPillFor(chore.status),
        ],
      ),
    );
  }
}

/// The colored Done / Overdue / To do label.
Widget statusPillFor(ChoreStatus status) {
  switch (status) {
    case ChoreStatus.done:
      return const StatusPill('Done', kind: PillKind.lime);
    case ChoreStatus.overdue:
      return const StatusPill('Overdue', kind: PillKind.pink);
    case ChoreStatus.todo:
      return const StatusPill('To do', kind: PillKind.lightBlue);
  }
}
