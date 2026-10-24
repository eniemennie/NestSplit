import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/ns_card.dart';
import '../../core/widgets/snack.dart';
import '../../state/app_services.dart';
import 'landlord_widgets.dart';

/// Screen 19: write a notice and send it to all tenants.
class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final property = AppScope.of(context).property;
    if (_controller.text.trim().isEmpty) {
      showNsSnack(context, 'Write a notice first');
      return;
    }
    property.sendNotice(_controller.text);
    _controller.clear();
    FocusScope.of(context).unfocus();
    showNsSnack(context, 'Notice sent to all tenants');
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
            const LandlordHeader(overline: 'Tenants', title: 'Announcements'),
            const SizedBox(height: 16),
            NsCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('New notice', style: AppText.sectionTitle),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _controller,
                    minLines: 4,
                    maxLines: 6,
                    style: AppText.body,
                    decoration: InputDecoration(
                      hintText: 'Write a notice for your tenants...',
                      hintStyle: AppText.bodyMuted,
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TriBandButton(label: 'Send to all tenants', icon: Icons.send_rounded, onPressed: _send),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text('Past notices', style: AppText.sectionTitle),
            const SizedBox(height: 10),
            for (final n in property.notices) ...[
              NsCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, color: AppColors.navy, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(n.title, style: AppText.cardTitle),
                          const SizedBox(height: 2),
                          Text(n.dateLabel, style: AppText.caption),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ],
        );
      },
    );
  }
}
