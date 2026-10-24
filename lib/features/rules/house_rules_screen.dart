import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/dashed_box.dart';
import '../../core/widgets/ns_card.dart';
import '../../core/widgets/ns_header.dart';
import '../../core/widgets/text_prompt.dart';
import '../../state/app_services.dart';

/// Screen 11: shared ground rules. Everyone in the house can add one.
class HouseRulesScreen extends StatelessWidget {
  const HouseRulesScreen({super.key});

  static const List<Color> _numberColors = [AppColors.blue, AppColors.pink, AppColors.lime];

  @override
  Widget build(BuildContext context) {
    final household = AppScope.of(context).household;
    return ListenableBuilder(
      listenable: household,
      builder: (context, _) {
        return SubPage(
          title: 'House rules',
          children: [
            for (var i = 0; i < household.rules.length; i++) ...[
              NsCard(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                radius: 12,
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: _numberColors[i % 3], borderRadius: BorderRadius.circular(8)),
                      child: Text('${i + 1}', style: AppText.cardTitle.copyWith(fontSize: 13)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(household.rules[i].text, style: AppText.body)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
            DashedBox(
              onTap: () async {
                final text = await showTextPrompt(context, title: 'Add a rule', hint: 'e.g. No shoes inside', confirmLabel: 'Add');
                if (text != null && text.isNotEmpty) household.addRule(text);
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, color: AppColors.muted, size: 20),
                  SizedBox(width: 6),
                  Text('Add a rule', style: AppText.bodyMuted),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Center(child: Text('Everyone in the house can add or edit rules.', style: AppText.caption)),
          ],
        );
      },
    );
  }
}
