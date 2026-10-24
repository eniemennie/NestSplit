import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/member_avatar.dart';
import '../../core/widgets/ns_card.dart';
import '../../core/widgets/segmented_bar.dart';
import '../../core/widgets/snack.dart';
import '../../core/widgets/status_pill.dart';
import '../../data/models/landlord_models.dart';
import '../../state/app_services.dart';
import 'landlord_widgets.dart';

/// Screen 17: who paid this month, mark late rent as received, see what is due next.
class RentTrackerScreen extends StatelessWidget {
  const RentTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final property = AppScope.of(context).property;
    return ListenableBuilder(
      listenable: property,
      builder: (context, _) {
        final total = property.monthlyRent.length;
        return LandlordPage(
          children: [
            const LandlordHeader(overline: 'Money', title: 'Rent tracker'),
            const SizedBox(height: 16),
            NsCard(
              color: AppColors.infoBlue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(child: Text('OCTOBER 2026', style: AppText.overline)),
                      if (property.lateCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.pink, borderRadius: BorderRadius.circular(20)),
                          child: Text('${property.lateCount} late', style: AppText.pill),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: Money.pesos(property.collectedCentavos), style: AppText.screenTitle.copyWith(fontSize: 26)),
                        TextSpan(text: ' / ${Money.pesos(property.expectedCentavos)}', style: AppText.bodyMuted),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SegmentedBar(
                    height: 10,
                    trackColor: AppColors.white,
                    segments: [
                      BarSegment(AppColors.lime, property.paidCount.toDouble()),
                      BarSegment(AppColors.white, (total - property.paidCount).toDouble()),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('${property.paidCount} paid · ${property.lateCount} late', style: AppText.cardTitle.copyWith(fontSize: 12.5)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text('Monthly rent', style: AppText.sectionTitle),
            const SizedBox(height: 10),
            for (final r in property.monthlyRent) ...[
              NsCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        MemberAvatar(member: r.tenant, size: 38),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Room ${r.roomNumber} · ${r.tenant.name}', style: AppText.cardTitle),
                              const SizedBox(height: 2),
                              Text(r.dueLabel, style: AppText.caption),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(Money.pesos(r.amountCentavos), style: AppText.cardTitle),
                            const SizedBox(height: 4),
                            if (r.status == RentStatus.paid)
                              const StatusPill('Paid', kind: PillKind.lime)
                            else
                              const StatusPill('Late', kind: PillKind.pink),
                          ],
                        ),
                      ],
                    ),
                    if (r.status == RentStatus.late) ...[
                      const SizedBox(height: 12),
                      TriBandButton(
                        label: 'Mark as received',
                        height: 44,
                        onPressed: () {
                          property.markRentReceived(r.id);
                          showNsSnack(context, 'Room ${r.roomNumber} marked as received');
                        },
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
            if (property.upcomingRent.isNotEmpty) ...[
              const SizedBox(height: 8),
              for (final r in property.upcomingRent)
                NsCard(
                  color: AppColors.background,
                  borderColor: AppColors.border,
                  borderWidth: 1,
                  child: Row(
                    children: [
                      const Icon(Icons.event_outlined, color: AppColors.navy),
                      const SizedBox(width: 12),
                      Expanded(child: Text('Next rent · ${r.dueLabel}', style: AppText.cardTitle)),
                      const StatusPill('Due', kind: PillKind.lightBlue),
                    ],
                  ),
                ),
            ],
          ],
        );
      },
    );
  }
}
