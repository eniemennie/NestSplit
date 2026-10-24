import 'package:flutter_test/flutter_test.dart';
import 'package:nestsplit_app/core/utils/validators.dart';
import 'package:nestsplit_app/data/models/user_account.dart';
import 'package:nestsplit_app/data/repositories/auth_repository.dart';
import 'package:nestsplit_app/data/repositories/mock_auth_repository.dart';

void main() {
  group('MockAuthRepository', () {
    test('signs in a demo account', () async {
      final repo = MockAuthRepository();
      final acc = await repo.signIn(email: 'BEN@nestsplit.test', password: 'Nest1234');
      expect(acc.name, 'Ben');
      expect(acc.role, AccountRole.tenant);
    });

    test('rejects a wrong password', () async {
      final repo = MockAuthRepository();
      expect(
        () => repo.signIn(email: 'ben@nestsplit.test', password: 'nope'),
        throwsA(isA<AuthException>()),
      );
    });

    test('registers, blocks duplicate email, changes password', () async {
      final repo = MockAuthRepository();
      final acc = await repo.register(
        name: 'Eli',
        email: 'eli@example.com',
        password: 'Secret123',
        role: AccountRole.landlord,
      );
      expect(
        () => repo.register(name: 'Eli2', email: 'eli@example.com', password: 'Secret123', role: AccountRole.landlord),
        throwsA(isA<AuthException>()),
      );
      await repo.changePassword(accountId: acc.id, currentPassword: 'Secret123', newPassword: 'Newpass456');
      final again = await repo.signIn(email: 'eli@example.com', password: 'Newpass456');
      expect(again.id, acc.id);
    });
  });

  group('Validators', () {
    test('email', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('abc'), isNotNull);
      expect(Validators.email('a@b.co'), isNull);
    });
    test('password rules', () {
      expect(Validators.newPassword('short1'), isNotNull);
      expect(Validators.newPassword('onlyletters'), isNotNull);
      expect(Validators.newPassword('Nest1234'), isNull);
    });
  });
}
