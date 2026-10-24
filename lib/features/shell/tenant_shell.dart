import 'package:flutter/material.dart';
import '../../core/widgets/ns_bottom_nav.dart';
import '../../state/app_services.dart';
import '../chores/chores_screen.dart';
import '../home/home_screen.dart';
import '../more/more_screen.dart';
import '../progress/progress_screen.dart';

/// Tenant app frame: four tabs (Home, Chores, Progress, More) and the floating bottom bar.
/// Other screens are pushed on top and show a back button instead of the bar.
class TenantShell extends StatelessWidget {
  const TenantShell({super.key});

  static const List<NavItem> _items = [
    NavItem(Icons.home_outlined, 'Home'),
    NavItem(Icons.checklist_rounded, 'Chores'),
    NavItem(Icons.bar_chart_rounded, 'Progress'),
    NavItem(Icons.grid_view_rounded, 'More'),
  ];

  @override
  Widget build(BuildContext context) {
    final tab = AppScope.of(context).tenantTab;
    return ValueListenableBuilder<int>(
      valueListenable: tab,
      builder: (context, index, _) {
        return Scaffold(
          body: IndexedStack(
            index: index,
            children: const [HomeScreen(), ChoresScreen(), ProgressScreen(), MoreScreen()],
          ),
          bottomNavigationBar: NsBottomNav(
            items: _items,
            currentIndex: index,
            onTap: (i) => tab.value = i,
          ),
        );
      },
    );
  }
}
