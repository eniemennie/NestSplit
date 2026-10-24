import '../models/user_account.dart';
import 'auth_repository.dart';

/// TEMPORARY local sign-in for the prototype. Accounts live in memory only, so
/// anything registered is lost when the app restarts. Passwords are kept as plain
/// text here, which is NOT safe: never do this with a real backend.
///
/// Demo accounts (fake, for testing only), password `Nest1234`:
///   ben@nestsplit.test, ana@nestsplit.test (tenants), landlord@nestsplit.test
class MockAuthRepository implements AuthRepository {
  MockAuthRepository() {
    _add(const UserAccount(id: 'u-ben', name: 'Ben', email: 'ben@nestsplit.test', role: AccountRole.tenant, memberId: 'ben'));
    _add(const UserAccount(id: 'u-ana', name: 'Ana', email: 'ana@nestsplit.test', role: AccountRole.tenant, memberId: 'ana'));
    _add(const UserAccount(id: 'u-landlord', name: 'Lakbay Landlord', email: 'landlord@nestsplit.test', role: AccountRole.landlord));
  }

  static const String demoPassword = 'Nest1234';

  final Map<String, UserAccount> _accounts = <String, UserAccount>{}; // by email
  final Map<String, String> _passwords = <String, String>{}; // by account id
  int _counter = 0;

  void _add(UserAccount account) {
    _accounts[account.email.toLowerCase()] = account;
    _passwords[account.id] = demoPassword;
  }

  @override
  Future<UserAccount> signIn({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final account = _accounts[email.trim().toLowerCase()];
    if (account == null || _passwords[account.id] != password) {
      throw const AuthException('Incorrect email or password.');
    }
    return account;
  }

  @override
  Future<UserAccount> register({
    required String name,
    required String email,
    required String password,
    required AccountRole role,
    String? memberId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final key = email.trim().toLowerCase();
    if (_accounts.containsKey(key)) {
      throw const AuthException('An account with this email already exists.');
    }
    _counter += 1;
    final account = UserAccount(
      id: 'u-new-$_counter',
      name: name.trim(),
      email: key,
      role: role,
      memberId: memberId,
    );
    _accounts[key] = account;
    _passwords[account.id] = password;
    return account;
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<UserAccount> updateName({required String accountId, required String name}) async {
    final entry = _accounts.entries.firstWhere((e) => e.value.id == accountId);
    final updated = entry.value.copyWith(name: name.trim());
    _accounts[entry.key] = updated;
    return updated;
  }

  @override
  Future<void> changePassword({
    required String accountId,
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_passwords[accountId] != currentPassword) {
      throw const AuthException('Current password is incorrect.');
    }
    _passwords[accountId] = newPassword;
  }
}
