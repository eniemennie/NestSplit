import 'package:flutter/widgets.dart';

import '../data/models/user_account.dart';
import '../data/repositories/app_repository.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/mock_auth_repository.dart';
import 'household_state.dart';
import 'property_state.dart';

enum UserRole { tenant, landlord }

/// Holds everything the UI needs: the repository, both state objects, the signed-in
/// role and the selected bottom-tab indexes. Created once in main.dart.
class AppServices {
  AppServices(this.repository, {AuthRepository? auth})
      : auth = auth ?? MockAuthRepository(),
        household = HouseholdState(repository),
        property = PropertyState(repository);

  final AppRepository repository;
  final AuthRepository auth;
  final HouseholdState household;
  final PropertyState property;

  /// null = signed out (login screen).
  final ValueNotifier<UserRole?> role = ValueNotifier<UserRole?>(null);

  /// The signed-in account (null = signed out).
  final ValueNotifier<UserAccount?> account = ValueNotifier<UserAccount?>(null);

  /// Selected bottom tab for each role.
  final ValueNotifier<int> tenantTab = ValueNotifier<int>(0);
  final ValueNotifier<int> landlordTab = ValueNotifier<int>(0);

  /// Which page the landlord "More" tab shows: 0 hub, 1 maintenance, 2 announcements, 3 rule templates.
  final ValueNotifier<int> landlordMorePage = ValueNotifier<int>(0);

  Future<void> loadAll() async {
    await household.load();
    await property.load();
  }

  /// Checks the email and password, then opens the tenant or landlord side.
  /// Throws [AuthException] with a message that is safe to show.
  Future<void> login(String email, String password) async {
    final acc = await auth.signIn(email: email, password: password);
    _enter(acc);
  }

  /// Creates an account and signs in. Tenants must give the household invite code.
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required AccountRole role,
    String inviteCode = '',
  }) async {
    String? memberId;
    if (role == AccountRole.tenant) {
      if (inviteCode.trim().toUpperCase() != household.inviteCode.toUpperCase()) {
        throw const AuthException('That invite code does not match a home.');
      }
      memberId = household.addMember(name).id;
    }
    try {
      final acc = await auth.register(name: name, email: email, password: password, role: role, memberId: memberId);
      _enter(acc);
    } on AuthException {
      if (memberId != null) household.removeMember(memberId);
      rethrow;
    }
  }

  Future<void> updateName(String name) async {
    final current = account.value;
    if (current == null || name.trim().isEmpty) return;
    final updated = await auth.updateName(accountId: current.id, name: name);
    account.value = updated;
    if (updated.memberId != null) household.renameMember(updated.memberId!, updated.name);
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    final current = account.value;
    if (current == null) return;
    await auth.changePassword(accountId: current.id, currentPassword: currentPassword, newPassword: newPassword);
  }

  void _enter(UserAccount acc) {
    if (acc.role == AccountRole.tenant && acc.memberId != null) {
      household.setCurrentUser(acc.memberId!);
    }
    tenantTab.value = 0;
    landlordTab.value = 0;
    landlordMorePage.value = 0;
    account.value = acc;
    role.value = acc.role == AccountRole.tenant ? UserRole.tenant : UserRole.landlord;
  }

  /// Lets us close any pushed screens when logging out.
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void signOut() {
    auth.signOut();
    navigatorKey.currentState?.popUntil((route) => route.isFirst);
    account.value = null;
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
