import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/member_avatar.dart';
import '../../core/widgets/ns_card.dart';
import '../../core/widgets/ns_header.dart';
import '../../core/widgets/ns_switch.dart';
import '../../core/widgets/snack.dart';
import '../../state/app_services.dart';

/// Screen 12: roster, invite code, personal stats, notification toggles and log out.
class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key});

  Future<void> _copy(BuildContext context, String code, String message) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!context.mounted) return;
    showNsSnack(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);
    final household = services.household;
    return ListenableBuilder(
      listenable: household,
      builder: (context, _) {
        final user = household.currentUser;
        final done = household.doneThisWeek[user.id] ?? 0;
        final streak = household.streakWeeks[user.id] ?? 0;
        return SubPage(
          title: 'Members',
          children: [
            Row(
              children: [
                for (final m in household.members)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        MemberAvatar(member: m, size: 54, radius: 14),
                        const SizedBox(height: 6),
                        Text(m.name, style: AppText.caption.copyWith(color: AppColors.navy, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            NsCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Invite code', style: AppText.caption),
                  const SizedBox(height: 4),
                  Text(household.inviteCode, style: AppText.screenTitle.copyWith(fontSize: 26, letterSpacing: 3)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _SmallButton(
                          label: 'Copy',
                          icon: Icons.copy_rounded,
                          background: AppColors.lime,
                          foreground: AppColors.navy,
                          onTap: () => _copy(context, household.inviteCode, 'Invite code copied.'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SmallButton(
                          label: 'Share',
                          icon: Icons.share_outlined,
                          background: AppColors.navy,
                          foreground: AppColors.white,
                          // TODO: use the share sheet once a share package is added.
                          onTap: () => _copy(context, 'Join ${household.householdName} on NestSplit with code ${household.inviteCode}', 'Invite message copied.'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            NsCard(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                children: [
                  _Stat(value: '$done', label: 'done'),
                  _Stat(value: '${household.sharePercent(user.id)}%', label: 'share'),
                  _Stat(value: '${streak}wk', label: 'streak'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            NsCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Column(
                children: [
                  _ToggleRow(label: 'Chore reminders', value: household.choreReminders, onChanged: household.setChoreReminders),
                  _ToggleRow(label: 'Swap requests', value: household.swapNotifications, onChanged: household.setSwapNotifications),
                  _ToggleRow(label: 'Weekly recap', value: household.weeklyRecapNotifications, onChanged: household.setWeeklyRecapNotifications),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  services.signOut();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.navy),
                label: const Text('Log out', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SmallButton extends StatelessWidget {
  const _SmallButton({required this.label, required this.icon, required this.background, required this.foreground, required this.onTap});

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: foreground),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: foreground, fontWeight: FontWeight.w800, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppText.sectionTitle.copyWith(fontSize: 20)),
          const SizedBox(height: 2),
          Text(label, style: AppText.caption),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({required this.label, required this.value, required this.onChanged});

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppText.cardTitle)),
          NsSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
