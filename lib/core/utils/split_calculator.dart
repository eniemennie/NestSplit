/// A payment one person owes another, in centavos.
class Transfer {
  const Transfer({required this.fromId, required this.toId, required this.amount});
  final String fromId;
  final String toId;
  final int amount;
}

/// Pure functions for the Quick Split feature. No Flutter or backend code here,
/// so it is easy to unit test and to move to a server later.
///
/// All amounts are whole centavos to avoid floating-point rounding errors.
class SplitCalculator {
  SplitCalculator._();

  /// Splits [totalCentavos] equally between [participantIds].
  /// Leftover centavos go one each to the first participants, so shares always
  /// add up to the total (1000 pesos / 3 = 333.34, 333.33, 333.33).
  static Map<String, int> equalShares(int totalCentavos, List<String> participantIds) {
    if (participantIds.isEmpty || totalCentavos <= 0) return <String, int>{};
    final count = participantIds.length;
    final base = totalCentavos ~/ count;
    final remainder = totalCentavos % count;
    final shares = <String, int>{};
    for (var i = 0; i < count; i++) {
      shares[participantIds[i]] = base + (i < remainder ? 1 : 0);
    }
    return shares;
  }

  /// For one expense: everyone except the payer owes the payer their share.
  static List<Transfer> owedToPayer({
    required int totalCentavos,
    required String payerId,
    required List<String> participantIds,
  }) {
    final shares = equalShares(totalCentavos, participantIds);
    final transfers = <Transfer>[];
    shares.forEach((id, amount) {
      if (id != payerId && amount > 0) {
        transfers.add(Transfer(fromId: id, toId: payerId, amount: amount));
      }
    });
    return transfers;
  }

  /// Turns net balances (positive = is owed, negative = owes) into the smallest
  /// practical list of payments. Greedy matching of the biggest debtor and creditor.
  static List<Transfer> simplify(Map<String, int> balances) {
    final creditors = <String, int>{};
    final debtors = <String, int>{};
    balances.forEach((id, amount) {
      if (amount > 0) creditors[id] = amount;
      if (amount < 0) debtors[id] = -amount;
    });
    final result = <Transfer>[];
    while (creditors.isNotEmpty && debtors.isNotEmpty) {
      final creditor = _largest(creditors);
      final debtor = _largest(debtors);
      final pay = creditors[creditor]! < debtors[debtor]! ? creditors[creditor]! : debtors[debtor]!;
      result.add(Transfer(fromId: debtor, toId: creditor, amount: pay));
      creditors[creditor] = creditors[creditor]! - pay;
      debtors[debtor] = debtors[debtor]! - pay;
      if (creditors[creditor] == 0) creditors.remove(creditor);
      if (debtors[debtor] == 0) debtors.remove(debtor);
    }
    return result;
  }

  static String _largest(Map<String, int> values) {
    String? bestId;
    var best = -1;
    values.forEach((id, amount) {
      if (amount > best) {
        best = amount;
        bestId = id;
      }
    });
    return bestId!;
  }
}
