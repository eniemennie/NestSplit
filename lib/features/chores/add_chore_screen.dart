import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/member_avatar.dart';
import '../../core/widgets/ns_card.dart';
import '../../core/widgets/ns_chip.dart';
import '../../core/widgets/ns_header.dart';
import '../../core/widgets/ns_switch.dart';
import '../../core/widgets/snack.dart';
import '../../data/models/chore.dart';
import '../../state/app_services.dart';

/// Screen 8: create a chore, pick how often and how hard, and preview the rotation.
class AddChoreScreen extends StatefulWidget {
  const AddChoreScreen({super.key});

  @override
  State<AddChoreScreen> createState() => _AddChoreScreenState();
}

class _AddChoreScreenState extends State<AddChoreScreen> {
  final TextEditingController _name = TextEditingController();
  Frequency _frequency = Frequency.weekly;
  Difficulty _difficulty = Difficulty.medium;
  bool? _rotate;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    final household = AppScope.of(context).household;
    final name = _name.text.trim();
    if (name.isEmpty) {
      showNsSnack(context, 'Give the chore a name first.');
      return;
    }
    final rotate = _rotate ?? household.autoRotate;
    final preview = household.rotationPreview();
    final assignee = rotate && preview.isNotEmpty ? preview.first.id : household.currentUserId;
    household.addChore(name: name, frequency: _frequency, difficulty: _difficulty, assigneeId: assignee);
    showNsSnack(context, 'Chore added: $name');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final household = AppScope.of(context).household;
    final rotate = _rotate ?? household.autoRotate;
    final preview = household.rotationPreview();
    return SubPage(
      title: 'New chore',
      bottom: PrimaryButton(label: 'Save chore', onPressed: _save),
      children: [
        TextField(
          controller: _name,
          textCapitalization: TextCapitalization.sentences,
          style: AppText.cardTitle,
          decoration: InputDecoration(
            hintText: 'Chore name',
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.navy, width: 1.6)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.navy, width: 1.6)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.navy, width: 2.2)),
          ),
        ),
        const SizedBox(height: 18),
        const Text('Frequency', style: AppText.sectionTitle),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: [
            NsChip(label: 'Daily', selected: _frequency == Frequency.daily, onTap: () => setState(() => _frequency = Frequency.daily)),
            NsChip(label: 'Weekly', selected: _frequency == Frequency.weekly, onTap: () => setState(() => _frequency = Frequency.weekly)),
            NsChip(label: 'Twice a week', selected: _frequency == Frequency.twiceAWeek, onTap: () => setState(() => _frequency = Frequency.twiceAWeek)),
          ],
        ),
        const SizedBox(height: 18),
        const Text('Difficulty', style: AppText.sectionTitle),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: [
            NsChip(label: 'Light', color: AppColors.lime, outlineWhenSelected: true, selected: _difficulty == Difficulty.light, onTap: () => setState(() => _difficulty = Difficulty.light)),
            NsChip(label: 'Medium', color: AppColors.blue, outlineWhenSelected: true, selected: _difficulty == Difficulty.medium, onTap: () => setState(() => _difficulty = Difficulty.medium)),
            NsChip(label: 'Heavy', color: AppColors.pink, outlineWhenSelected: true, selected: _difficulty == Difficulty.heavy, onTap: () => setState(() => _difficulty = Difficulty.heavy)),
          ],
        ),
        const SizedBox(height: 16),
        NsCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const Expanded(child: Text('Rotate automatically', style: AppText.cardTitle)),
              NsSwitch(value: rotate, onChanged: (v) => setState(() => _rotate = v)),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text('Rotation preview', style: AppText.sectionTitle),
        const SizedBox(height: 10),
        NsCard(
          child: Column(
            children: [
              for (var i = 0; i < preview.length; i++)
                Padding(
                  padding: EdgeInsets.only(top: i == 0 ? 0 : 12),
                  child: Row(
                    children: [
                      SizedBox(width: 70, child: Text('Week ${i + 1}', style: AppText.bodyMuted)),
                      MemberAvatar(member: preview[i], size: 24),
                      const SizedBox(width: 10),
                      Text(preview[i].name, style: AppText.cardTitle),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
