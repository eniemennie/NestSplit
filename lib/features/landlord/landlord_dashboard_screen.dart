import 'package:flutter/material.dart';
import '../../core/widgets/brand_logo.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/icon_tile.dart';
import '../../core/widgets/ns_card.dart';
import '../../core/widgets/segmented_bar.dart';
import '../../core/widgets/status_pill.dart';
import '../../state/app_services.dart';
import 'landlord_widgets.dart';

/// Screen 15: rooms, rent collected, open repairs and the latest activity.
class LandlordDashboardScreen extends StatelessWidget {
  const LandlordDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);
    final property = services.property;
    return ListenableBuilder(
      listenable: property,
      builder: (context, _) {
        final late = property.firstLate;
        const triColors = [AppColors.blue, AppColors.pink, AppColors.lime];
        final segments = <BarSegment>[];
        var paidIndex = 0;
        for (final r in property.monthlyRent) {
          if (r.status.name == 'paid') {
            segments.add(BarSegment(triColors[paidIndex % 3], 1));
            paidIndex += 1;
          }
        }
        final unpaid = property.monthlyRent.length - paidIndex;
        if (unpaid > 0) segments.add(BarSegment(AppColors.chipGrey, unpaid.toDouble()));

        return LandlordPage(
          children: [
            LandlordHeader(
              overline: 'Landlord view',
              title: property.propertyName,
              onTitleTap: property.propertyCount > 1 ? () => showPropertyPicker(context, property) : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  BrandLogo(size: 38),
                  SizedBox(width: 8),
                  SquareIconButton(icon: Icons.notifications_none_rounded, showDot: true, onPressed: null),
                ],
              ),
            ),
            const SizedBox(height: 16),
            NsCard(
              onTap: () => services.landlordTab.value = 1,
              child: Row(
                children: [
                  const IconTile(icon: Icons.apartment_rounded, background: AppColors.blue, size: 44),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${property.roomCount} rooms', style: AppText.sectionTitle),
                        const SizedBox(height: 2),
                        Text('${property.occupiedCount} occupied · ${property.availableCount} available', style: AppText.caption),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.navy),
                ],
              ),
            ),
            const SizedBox(height: 12),
            NsCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Expanded(child: Text('RENT COLLECTED · OCTOBER', style: AppText.overline)),
                      Icon(Icons.monetization_on_outlined, size: 22, color: AppColors.navy),
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
                  SegmentedBar(segments: segments, height: 10),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: Text('${property.paidCount} of ${property.monthlyRent.length} paid', style: AppText.cardTitle.copyWith(fontSize: 12.5))),
                      Text('${property.lateCount} late', style: AppText.cardTitle.copyWith(fontSize: 12.5)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: NsCard(
                    onTap: () {
                      services.landlordMorePage.value = 1;
                      services.landlordTab.value = 3;
                    },
                    child: Row(
                      children: [
                        const IconTile(icon: Icons.build_rounded, background: AppColors.pink, size: 38),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${property.openRepairCount}', style: AppText.sectionTitle.copyWith(fontSize: 20)),
                              const Text('Open repairs', style: AppText.caption),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NsCard(
                    onTap: () => services.landlordTab.value = 1,
                    child: Row(
                      children: [
                        const IconTile(icon: Icons.bed_rounded, background: AppColors.lime, size: 38),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${property.occupiedCount} / ${property.roomCount}', style: AppText.sectionTitle.copyWith(fontSize: 20)),
                              const Text('Rooms occupied', style: AppText.caption),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (late != null) ...[
              const SizedBox(height: 12),
              NsCard(
                color: AppColors.pink,
                padding: const EdgeInsets.all(14),
                onTap: () => services.landlordTab.value = 2,
                child: Row(
                  children: [
                    const IconTile(icon: Icons.schedule_rounded, background: AppColors.white, size: 38),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Room ${late.roomNumber} rent is late', style: AppText.cardTitle),
                          const SizedBox(height: 2),
                          Text('${late.tenant.name} · ${late.dueLabel.toLowerCase()}', style: AppText.caption.copyWith(color: AppColors.navy)),
                        ],
                      ),
                    ),
                    const StatusPill('Late', kind: PillKind.white),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: const [
                Expanded(child: Text('Recent activity', style: AppText.sectionTitle)),
                Text('October', style: AppText.caption),
              ],
            ),
            const SizedBox(height: 10),
            for (final text in property.recentActivity.take(5)) ...[
              NsCard(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                radius: 12,
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, size: 20, color: AppColors.navy),
                    const SizedBox(width: 10),
                    Expanded(child: Text(text, style: AppText.body.copyWith(fontSize: 13.5))),
                    const StatusPill('Paid', kind: PillKind.lime),
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
}
