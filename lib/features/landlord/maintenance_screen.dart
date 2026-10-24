import 'package:flutter/material.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/ns_card.dart';
import '../../core/widgets/status_pill.dart';
import '../../core/widgets/step_bar.dart';
import '../../data/models/landlord_models.dart';
import '../../state/app_services.dart';
import 'landlord_widgets.dart';

/// Screen 18: repair requests with a 3-step tracker.
class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  int _stageIndex(RepairStage s) {
    switch (s) {
      case RepairStage.reported:
        return 0;
      case RepairStage.inProgress:
        return 1;
      case RepairStage.fixed:
        return 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);
    final property = services.property;
    return ListenableBuilder(
      listenable: property,
      builder: (context, _) {
        return LandlordPage(
          children: [
            LandlordBackRow(onBack: () => services.landlordMorePage.value = 0),
            const LandlordHeader(overline: 'Property', title: 'Maintenance'),
            const SizedBox(height: 16),
            Text('Repair requests · ${property.openRepairCount} open', style: AppText.sectionTitle),
            const SizedBox(height: 10),
            for (final r in property.openRepairs) ...[
              NsCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.title, style: AppText.cardTitle),
                    const SizedBox(height: 2),
                    Text(r.detail, style: AppText.caption),
                    const SizedBox(height: 12),
                    StepBar(currentIndex: _stageIndex(r.stage)),
                    const SizedBox(height: 12),
                    TriBandButton(label: 'Update status', height: 44, onPressed: () => property.advanceRepair(r.id)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
            if (property.fixedRepairs.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Recently fixed', style: AppText.sectionTitle),
              const SizedBox(height: 10),
              for (final r in property.fixedRepairs) ...[
                NsCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(r.title, style: AppText.cardTitle)),
                          const StatusPill('Fixed', kind: PillKind.lime),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(r.detail, style: AppText.caption),
                      const SizedBox(height: 10),
                      const StepBar(currentIndex: 3, showLabels: false),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ],
        );
      },
    );
  }
}
