import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/icon_tile.dart';
import '../../core/widgets/member_avatar.dart';
import '../../core/widgets/ns_card.dart';
import '../../core/widgets/snack.dart';
import '../../core/widgets/status_pill.dart';
import '../../data/models/landlord_models.dart';
import '../../state/app_services.dart';
import 'landlord_widgets.dart';

/// Screen 16: all rooms, who lives there and the tenant invite code.
class RoomsScreen extends StatelessWidget {
  const RoomsScreen({super.key});

  StatusPill _pill(RentStatus s) {
    switch (s) {
      case RentStatus.paid:
        return const StatusPill('Paid', kind: PillKind.lime);
      case RentStatus.late:
        return const StatusPill('Late', kind: PillKind.pink);
      case RentStatus.due:
        return const StatusPill('Due', kind: PillKind.lightBlue);
      case RentStatus.vacant:
        return const StatusPill('Vacant', kind: PillKind.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final property = AppScope.of(context).property;
    return ListenableBuilder(
      listenable: property,
      builder: (context, _) {
        return LandlordPage(
          children: [
            LandlordHeader(
              overline: 'Property',
              title: 'Rooms',
              trailing: SquareIconButton(
                icon: Icons.add_rounded,
                background: AppColors.navy,
                iconColor: AppColors.white,
                onPressed: () => showNsSnack(context, 'Adding rooms comes later (prototype)'),
              ),
            ),
            const SizedBox(height: 16),
            NsCard(
              onTap: property.propertyCount > 1 ? () => showPropertyPicker(context, property) : null,
              child: Row(
                children: [
                  const IconTile(icon: Icons.apartment_rounded, background: AppColors.blue, size: 44),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(property.propertyName, style: AppText.sectionTitle),
                        const SizedBox(height: 2),
                        Text('${property.roomCount} rooms · ${property.occupiedCount} occupied', style: AppText.caption),
                      ],
                    ),
                  ),
                  if (property.propertyCount > 1) const Icon(Icons.unfold_more_rounded, color: AppColors.navy),
                ],
              ),
            ),
            const SizedBox(height: 14),
            for (final room in property.rooms) ...[
              NsCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    if (room.tenant != null)
                      MemberAvatar(member: room.tenant!, size: 40)
                    else
                      const IconTile(icon: Icons.bed_rounded, background: AppColors.chipGrey, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            room.tenant == null ? 'Room ${room.number}' : 'Room ${room.number} · ${room.tenant!.name}',
                            style: AppText.cardTitle,
                          ),
                          const SizedBox(height: 2),
                          Text(room.subtitle, style: AppText.caption),
                        ],
                      ),
                    ),
                    _pill(room.status),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 6),
            NsCard(
              color: AppColors.todoBlue,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tenant invite code', style: AppText.caption),
                        const SizedBox(height: 2),
                        Text(property.inviteCode, style: AppText.sectionTitle.copyWith(fontSize: 20)),
                      ],
                    ),
                  ),
                  // PrimaryButton is full-width, so it needs a fixed width inside a Row.
                  SizedBox(
                    width: 112,
                    child: PrimaryButton(
                      label: 'Copy',
                      height: 40,
                      icon: Icons.copy_rounded,
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: property.inviteCode));
                        showNsSnack(context, 'Invite code copied');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
