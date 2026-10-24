import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/member_avatar.dart';
import '../../core/widgets/ns_card.dart';
import '../../core/widgets/snack.dart';
import '../../core/widgets/status_pill.dart';
import '../../state/app_services.dart';
import 'landlord_widgets.dart';

/// Screen 20: pick a house-rule template, send it to tenants, see who accepted.
class RuleTemplatesScreen extends StatelessWidget {
  const RuleTemplatesScreen({super.key});

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
            const LandlordHeader(overline: 'Tenants', title: 'Rule templates'),
            const SizedBox(height: 16),
            for (final t in property.templates) ...[
              NsCard(
                color: t.id == property.selectedTemplateId ? AppColors.todoBlue : AppColors.white,
                borderColor: t.id == property.selectedTemplateId ? AppColors.navy : null,
                borderWidth: t.id == property.selectedTemplateId ? 1.6 : 0,
                onTap: () => property.selectTemplate(t.id),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.title, style: AppText.cardTitle),
                          const SizedBox(height: 2),
                          Text(t.subtitle, style: AppText.caption),
                        ],
                      ),
                    ),
                    Icon(
                      t.id == property.selectedTemplateId ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      color: AppColors.navy,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 4),
            TriBandButton(
              label: 'Send to new tenants',
              icon: Icons.send_rounded,
              onPressed: () {
                property.sendTemplateToTenants();
                showNsSnack(context, 'Template sent to tenants');
              },
            ),
            const SizedBox(height: 18),
            const Text('Acceptance status', style: AppText.sectionTitle),
            const SizedBox(height: 10),
            for (final a in property.acceptances) ...[
              NsCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                radius: 14,
                child: Row(
                  children: [
                    MemberAvatar(member: a.tenant, size: 34),
                    const SizedBox(width: 12),
                    Expanded(child: Text(a.tenant.name, style: AppText.cardTitle)),
                    a.accepted
                        ? const StatusPill('Accepted', kind: PillKind.lime)
                        : const StatusPill('Pending', kind: PillKind.grey),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 6),
            const Center(child: Text('Acceptance is visible to the landlord.', style: AppText.caption)),
          ],
        );
      },
    );
  }
}
