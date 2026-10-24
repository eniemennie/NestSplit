import 'package:flutter_test/flutter_test.dart';
import 'package:nestsplit_app/core/utils/money.dart';
import 'package:nestsplit_app/core/utils/split_calculator.dart';

void main() {
  group('SplitCalculator.equalShares', () {
    test('splits evenly', () {
      final shares = SplitCalculator.equalShares(240000, ['a', 'b', 'c', 'd']);
      expect(shares.values.every((v) => v == 60000), isTrue);
    });

    test('gives remainder centavos to first people and keeps the total', () {
      final shares = SplitCalculator.equalShares(100000, ['a', 'b', 'c']);
      expect(shares['a'], 33334);
      expect(shares['b'], 33333);
      expect(shares['c'], 33333);
      expect(shares.values.fold<int>(0, (a, b) => a + b), 100000);
    });
  });

  group('SplitCalculator.owedToPayer', () {
    test('everyone except the payer owes the payer', () {
      final t = SplitCalculator.owedToPayer(
        totalCentavos: 240000,
        payerId: 'a',
        participantIds: ['a', 'b', 'c', 'd'],
      );
      expect(t.length, 3);
      expect(t.every((x) => x.toId == 'a' && x.amount == 60000), isTrue);
    });
  });

  group('SplitCalculator.simplify', () {
    test('settles balances with the fewest simple payments', () {
      final t = SplitCalculator.simplify({'a': 10000, 'b': -4000, 'c': -6000});
      expect(t.fold<int>(0, (a, x) => a + x.amount), 10000);
      expect(t.every((x) => x.toId == 'a'), isTrue);
    });
  });

  group('Money', () {
    test('formats pesos', () {
      expect(Money.pesos(240000), '₱2,400');
      expect(Money.pesos(125050), '₱1,250.50');
    });
    test('parses input', () {
      expect(Money.parseToCentavos('₱2,400'), 240000);
      expect(Money.parseToCentavos('abc'), isNull);
    });
  });
}
