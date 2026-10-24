import '../models/user_account.dart';

/// Shown to the user as-is, so keep messages short and friendly.
class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Everything the app needs from a sign-in system. [MockAuthRepository] is a local
/// stand-in; replace it with Firebase Auth or your own API by implementing this.
abstract class AuthRepository {
  /// Returns the account, or throws [AuthException] (wrong email or password).
  Future<UserAccount> signIn({required String email, required String password});

  /// Creates a new account, or throws [AuthException] (e.g. email already used).
  Future<UserAccount> register({
    required String name,
    required String email,
    required String password,
    required AccountRole role,
    String? memberId,
  });

  Future<void> signOut();

  Future<UserAccount> updateName({required String accountId, required String name});

  /// Throws [AuthException] if [currentPassword] is wrong.
  Future<void> changePassword({
    required String accountId,
    required String currentPassword,
    required String newPassword,
  });
}
