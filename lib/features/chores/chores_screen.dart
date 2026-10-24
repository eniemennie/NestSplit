import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/ns_card.dart';
import '../../core/widgets/ns_chip.dart';
import '../../core/widgets/ns_switch.dart';
import '../../data/models/chore.dart';
import '../../state/app_services.dart';
import 'add_chore_screen.dart';
import 'chore_detail_screen.dart';
import 'chore_row.dart';

/// Screen 3: weekly chore list with filters and the auto-rotate switch.
class ChoresScreen extends StatefulWidget {
  const ChoresScreen({super.key});

  @override
  State<ChoresScreen> createState() => _ChoresScreenState();
}

class _ChoresScreenState extends State<ChoresScreen> {
  // 0 = This week, 1 = Mine, 2 = Overdue
  int _filter = 0;

  @override
  Widget build(BuildContext context) {
    final household = AppScope.of(context).household;
    return SafeArea(
      child: ListenableBuilder(
        listenable: household,
        builder: (context, _) {
          List<Chore> visible;
          if (_filter == 1) {
            visible = household.chores.where((c) => c.assigneeId == household.currentUserId).toList();
          } else if (_filter == 2) {
            visible = household.chores.where((c) => c.status == ChoreStatus.overdue).toList();
          } else {
            visible = household.chores;
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            children: [
              Row(
                children: [
                  const Expanded(child: Text('Chores', style: AppText.screenTitle)),
                  SquareIconButton(
                    icon: Icons.add_rounded,
                    background: AppColors.navy,
                    iconColor: AppColors.white,
                    size: 44,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const AddChoreScreen()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  NsChip(label: 'This week', selected: _filter == 0, onTap: () => setState(() => _filter = 0)),
                  const SizedBox(width: 8),
                  NsChip(label: 'Mine', selected: _filter == 1, onTap: () => setState(() => _filter = 1)),
                  const SizedBox(width: 8),
                  NsChip(label: 'Overdue', selected: _filter == 2, onTap: () => setState(() => _filter = 2)),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: AppColors.lime, borderRadius: BorderRadius.circular(14)),
                child: Row(
                  children: [
                    const Icon(Icons.sync_rounded, size: 20, color: AppColors.navy),
                    const SizedBox(width: 10),
                    const Expanded(child: Text('Auto-rotate next week', style: AppText.cardTitle)),
                    NsSwitch(value: household.autoRotate, onChanged: household.setAutoRotate),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (visible.isEmpty)
                const NsCard(child: Text('No chores here. Nice!', style: AppText.bodyMuted))
              else
                for (final chore in visible) ...[
                  ChoreRow(
                    chore: chore,
                    assignee: household.memberById(chore.assigneeId),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => ChoreDetailScreen(choreId: chore.id)),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
            ],
          );
        },
      ),
    );
  }
}
