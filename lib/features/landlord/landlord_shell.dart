import 'package:flutter/material.dart';
import '../../core/widgets/ns_bottom_nav.dart';
import '../../state/app_services.dart';
import '../profile/profile_screen.dart';
import 'announcements_screen.dart';
import 'landlord_dashboard_screen.dart';
import 'landlord_more_screen.dart';
import 'maintenance_screen.dart';
import 'rent_tracker_screen.dart';
import 'rooms_screen.dart';
import 'rule_templates_screen.dart';

/// Landlord app frame: Dashboard, Rooms, Rent and More. The More tab shows a hub, and
/// Maintenance, Announcements and Rule templates open inside it with More still selected
/// (as in the mockup). Tap More again to return to the hub.
class LandlordShell extends StatelessWidget {
  const LandlordShell({super.key});

  static const List<NavItem> _items = [
    NavItem(Icons.apartment_rounded, 'Dashboard'),
    NavItem(Icons.bed_rounded, 'Rooms'),
    NavItem(Icons.attach_money_rounded, 'Rent'),
    NavItem(Icons.grid_view_rounded, 'More'),
    NavItem(Icons.person_outline_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);
    return ValueListenableBuilder<int>(
      valueListenable: services.landlordTab,
      builder: (context, tab, _) {
        return ValueListenableBuilder<int>(
          valueListenable: services.landlordMorePage,
          builder: (context, morePage, _) {
            Widget morePageWidget;
            switch (morePage) {
              case 1:
                morePageWidget = const MaintenanceScreen();
                break;
              case 2:
                morePageWidget = const AnnouncementsScreen();
                break;
              case 3:
                morePageWidget = const RuleTemplatesScreen();
                break;
              default:
                morePageWidget = const LandlordMoreScreen();
            }
            return Scaffold(
              body: IndexedStack(
                index: tab,
                children: [
                  const LandlordDashboardScreen(),
                  const RoomsScreen(),
                  const RentTrackerScreen(),
                  morePageWidget,
                  const ProfileScreen(),
                ],
              ),
              bottomNavigationBar: NsBottomNav(
                items: _items,
                currentIndex: tab,
                onTap: (i) {
                  if (i == 3 && tab == 3) services.landlordMorePage.value = 0;
                  services.landlordTab.value = i;
                },
              ),
            );
          },
        );
      },
    );
  }
}
