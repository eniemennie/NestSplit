import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/member_avatar.dart';
import '../../core/widgets/ns_card.dart';
import '../../core/widgets/ns_header.dart';
import '../../core/widgets/snack.dart';
import '../../core/widgets/status_pill.dart';
import '../../data/models/swap_request.dart';
import '../../state/app_services.dart';

/// Screen 9: ask a roommate to cover a chore, and answer requests from others.
class SwapsScreen extends StatelessWidget {
  const SwapsScreen({super.key});

  Future<void> _openRequestSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (sheetContext) => const _RequestSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final household = AppScope.of(context).household;
    return ListenableBuilder(
      listenable: household,
      builder: (context, _) {
        final incoming = household.incomingSwaps;
        final sent = household.sentSwaps;
        return SubPage(
          title: 'Swaps',
          children: [
            TriBandButton(label: 'Request coverage', onPressed: () => _openRequestSheet(context)),
            const SizedBox(height: 18),
            const Text('Incoming', style: AppText.sectionTitle),
            const SizedBox(height: 10),
            if (incoming.isEmpty)
              const NsCard(child: Text('No requests waiting for you.', style: AppText.bodyMuted))
            else
              for (final swap in incoming) ...[
                _IncomingCard(swap: swap),
                const SizedBox(height: 12),
              ],
            const SizedBox(height: 6),
            const Text('Sent', style: AppText.sectionTitle),
            const SizedBox(height: 10),
            if (sent.isEmpty)
              const NsCard(child: Text('You have not asked anyone yet.', style: AppText.bodyMuted))
            else
              for (final swap in sent) ...[
                NsCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  radius: 12,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${swap.offeredChore} → ${household.memberById(swap.targetId).name}',
                          style: AppText.cardTitle,
                        ),
                      ),
                      StatusPill(_label(swap.status), kind: _kind(swap.status)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
          ],
        );
      },
    );
  }

  static String _label(SwapStatus s) {
    switch (s) {
      case SwapStatus.pending:
        return 'Pending';
      case SwapStatus.approved:
        return 'Approved';
      case SwapStatus.declined:
        return 'Declined';
    }
  }

  static PillKind _kind(SwapStatus s) {
    switch (s) {
      case SwapStatus.pending:
        return PillKind.lightBlue;
      case SwapStatus.approved:
        return PillKind.lime;
      case SwapStatus.declined:
        return PillKind.pink;
    }
  }
}

class _IncomingCard extends StatelessWidget {
  const _IncomingCard({required this.swap});

  final SwapRequest swap;

  @override
  Widget build(BuildContext context) {
    final household = AppScope.of(context).household;
    final requester = household.memberById(swap.requesterId);
    return NsCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MemberAvatar(member: requester, size: 34),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${requester.name} asks to swap', style: AppText.cardTitle),
                    if (swap.reason.isNotEmpty) Text('"${swap.reason}"', style: AppText.caption),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              StatusPill(swap.offeredChore, kind: PillKind.blue),
              if (swap.requestedChore != null) ...[
                const Icon(Icons.swap_horiz_rounded, size: 18, color: AppColors.navy),
                StatusPill(swap.requestedChore!, kind: PillKind.pink),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: 'Approve',
                  height: 44,
                  onPressed: () {
                    household.resolveSwap(swap.id, SwapStatus.approved);
                    showNsSnack(context, 'Swap approved.');
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PrimaryButton(
                  label: 'Decline',
                  height: 44,
                  color: AppColors.chipGrey,
                  textColor: AppColors.navy,
                  onPressed: () {
                    household.resolveSwap(swap.id, SwapStatus.declined);
                    showNsSnack(context, 'Swap declined.');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet: pick one of your chores, a roommate and a short reason.
class _RequestSheet extends StatefulWidget {
  const _RequestSheet();

  @override
  State<_RequestSheet> createState() => _RequestSheetState();
}

class _RequestSheetState extends State<_RequestSheet> {
  final TextEditingController _reason = TextEditingController();
  String? _choreName;
  String? _targetId;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final household = AppScope.of(context).household;
    final myChores = household.myOpenChores;
    final others = household.members.where((m) => m.id != household.currentUserId).toList();
    _choreName ??= myChores.isNotEmpty ? myChores.first.name : null;
    _targetId ??= others.isNotEmpty ? others.first.id : null;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Request coverage', style: AppText.sectionTitle),
          const SizedBox(height: 14),
          if (myChores.isEmpty)
            const Text('You have no open chores to swap.', style: AppText.bodyMuted)
          else ...[
            const Text('Which chore?', style: AppText.caption),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in myChores)
                  GestureDetector(
                    onTap: () => setState(() => _choreName = c.name),
                    child: StatusPill(c.name, kind: _choreName == c.name ? PillKind.navy : PillKind.grey),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            const Text('Ask who?', style: AppText.caption),
            const SizedBox(height: 6),
            Row(
              children: [
                for (final m in others)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () => setState(() => _targetId = m.id),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _targetId == m.id ? AppColors.navy : Colors.transparent, width: 2),
                        ),
                        child: MemberAvatar(member: m, size: 38),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _reason,
              decoration: const InputDecoration(hintText: 'Reason (optional)'),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Send request',
              onPressed: () {
                if (_choreName == null || _targetId == null) return;
                household.requestCoverage(choreName: _choreName!, targetId: _targetId!, reason: _reason.text.trim());
                Navigator.of(context).pop();
              },
            ),
          ],
        ],
      ),
    );
  }
}
