/// Formats centavo amounts as Philippine pesos, e.g. 240000 -> "₱2,400".
class Money {
  Money._();

  static String pesos(int centavos) {
    final negative = centavos < 0;
    final abs = centavos.abs();
    final whole = abs ~/ 100;
    final cents = abs % 100;
    final digits = whole.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final remaining = digits.length - i;
      buffer.write(digits[i]);
      if (remaining > 1 && remaining % 3 == 1) buffer.write(',');
    }
    final centsText = cents == 0 ? '' : '.${cents.toString().padLeft(2, '0')}';
    return '${negative ? '-' : ''}₱$buffer$centsText';
  }

  /// Parses user input like "2,400" or "₱1250.50" into centavos. Returns null if invalid.
  static int? parseToCentavos(String input) {
    final cleaned = input.replaceAll('₱', '').replaceAll(',', '').trim();
    if (cleaned.isEmpty) return null;
    final value = double.tryParse(cleaned);
    if (value == null || value <= 0) return null;
    return (value * 100).round();
  }
}
