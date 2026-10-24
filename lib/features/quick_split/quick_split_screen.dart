import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/money.dart';
import '../../core/utils/split_calculator.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/member_avatar.dart';
import '../../core/widgets/ns_card.dart';
import '../../core/widgets/ns_header.dart';
import '../../core/widgets/snack.dart';
import '../../state/app_services.dart';

/// Screen 13: split one shared bill equally and see who owes whom.
/// The maths lives in core/utils/split_calculator.dart (unit tested).
class QuickSplitScreen extends StatefulWidget {
  const QuickSplitScreen({super.key});

  @override
  State<QuickSplitScreen> createState() => _QuickSplitScreenState();
}

class _QuickSplitScreenState extends State<QuickSplitScreen> {
  final TextEditingController _title = TextEditingController(text: 'Electric bill');
  final TextEditingController _amount = TextEditingController(text: '2400');
  String? _payerId;

  @override
  void initState() {
    super.initState();
    _title.addListener(_refresh);
    _amount.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final household = AppScope.of(context).household;
    final members = household.members;
    _payerId ??= members.first.id;
    final ids = members.map((m) => m.id).toList();
    final total = Money.parseToCentavos(_amount.text);
    final shares = total == null ? <String, int>{} : SplitCalculator.equalShares(total, ids);
    final transfers = total == null
        ? <Transfer>[]
        : SplitCalculator.owedToPayer(totalCentavos: total, payerId: _payerId!, participantIds: ids);
    final firstShare = shares.isEmpty ? 0 : shares.values.first;
    final allEqual = shares.values.every((v) => v == firstShare);

    return SubPage(
      title: 'Quick Split',
      bottom: TriBandButton(
        label: 'Add expense',
        onPressed: () {
          if (total == null) {
            showNsSnack(context, 'Enter an amount greater than zero.');
            return;
          }
          final title = _title.text.trim().isEmpty ? 'Shared expense' : _title.text.trim();
          household.addExpense(title: title, amountCentavos: total, payerId: _payerId!);
          showNsSnack(context, 'Added: $title, ${Money.pesos(total)}');
          Navigator.of(context).pop();
        },
      ),
      children: [
        NsCard(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            children: [
              TextField(
                controller: _title,
                textAlign: TextAlign.center,
                style: AppText.caption,
                decoration: const InputDecoration(border: InputBorder.none, isDense: true, hintText: 'What is it for?'),
              ),
              TextField(
                controller: _amount,
                textAlign: TextAlign.center,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: AppText.bigNumber,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  prefixText: '₱',
                  prefixStyle: AppText.bigNumber,
                  hintText: '0',
                ),
              ),
              Text(
                total == null ? 'Enter an amount' : 'Split equally · ${allEqual ? '' : 'about '}${Money.pesos(firstShare)} each',
                style: AppText.caption,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text('Who paid?', style: AppText.sectionTitle),
        const SizedBox(height: 10),
        Row(
          children: [
            for (final m in members)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => setState(() => _payerId = m.id),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _payerId == m.id ? AppColors.navy : Colors.transparent, width: 2),
                    ),
                    child: MemberAvatar(member: m, size: 46, radius: 12),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 18),
        const Text('Who owes whom', style: AppText.sectionTitle),
        const SizedBox(height: 10),
        NsCard(
          child: transfers.isEmpty
              ? const Text('Nothing to split yet.', style: AppText.bodyMuted)
              : Column(
                  children: [
                    for (var i = 0; i < transfers.length; i++)
                      Padding(
                        padding: EdgeInsets.only(top: i == 0 ? 0 : 12),
                        child: Row(
                          children: [
                            MemberAvatar(member: household.memberById(transfers[i].fromId), size: 24),
                            const SizedBox(width: 8),
                            Text(household.memberById(transfers[i].fromId).name, style: AppText.cardTitle.copyWith(fontSize: 13.5)),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.muted),
                            ),
                            MemberAvatar(member: household.memberById(transfers[i].toId), size: 24),
                            const SizedBox(width: 8),
                            Expanded(child: Text(household.memberById(transfers[i].toId).name, style: AppText.body.copyWith(fontSize: 13.5))),
                            Text(Money.pesos(transfers[i].amount), style: AppText.cardTitle),
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
