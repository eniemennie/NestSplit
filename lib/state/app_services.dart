import 'package:flutter/widgets.dart';

import '../data/repositories/app_repository.dart';
import 'household_state.dart';
import 'property_state.dart';

enum UserRole { tenant, landlord }

/// Holds everything the UI needs: the repository, both state objects, the signed-in
/// role and the selected bottom-tab indexes. Created once in main.dart.
class AppServices {
  AppServices(this.repository)
      : household = HouseholdState(repository),
        property = PropertyState(repository);

  final AppRepository repository;
  final HouseholdState household;
  final PropertyState property;

  /// null = signed out (login screen).
  final ValueNotifier<UserRole?> role = ValueNotifier<UserRole?>(null);

  /// Selected bottom tab for each role.
  final ValueNotifier<int> tenantTab = ValueNotifier<int>(0);
  final ValueNotifier<int> landlordTab = ValueNotifier<int>(0);

  /// Which page the landlord "More" tab shows: 0 hub, 1 maintenance, 2 announcements, 3 rule templates.
  final ValueNotifier<int> landlordMorePage = ValueNotifier<int>(0);

  Future<void> loadAll() async {
    await household.load();
    await property.load();
  }

  void signIn(UserRole value) {
    tenantTab.value = 0;
    landlordTab.value = 0;
    landlordMorePage.value = 0;
    role.value = value;
  }

  /// Lets us close any pushed screens when logging out.
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void signOut() {
    navigatorKey.currentState?.popUntil((route) => route.isFirst);
    role.value = null;
  }
}

/// Gives any widget access to [AppServices]: `AppScope.of(context)`.
class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.services, required super.child});

  final AppServices services;

  static AppServices of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found above this widget.');
    return scope!.services;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) => services != oldWidget.services;
}
