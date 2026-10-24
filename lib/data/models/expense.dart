/// A shared expense. Amounts are whole centavos (240000 = ₱2,400).
class Expense {
  const Expense({
    required this.id,
    required this.title,
    required this.amountCentavos,
    required this.payerId,
    required this.participantIds,
    required this.createdAt,
  });

  final String id;
  final String title;
  final int amountCentavos;
  final String payerId;
  final List<String> participantIds;
  final DateTime createdAt;
}
