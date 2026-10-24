/// Form checks used by the login, sign-up and profile screens.
/// Each returns an error message, or null when the value is fine.
class Validators {
  Validators._();

  static String? email(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Enter your email.';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) return 'Enter a valid email.';
    return null;
  }

  static String? requiredText(String value, String label) {
    if (value.trim().isEmpty) return 'Enter $label.';
    return null;
  }

  /// At least 8 characters with a letter and a number.
  static String? newPassword(String value) {
    if (value.length < 8) return 'Use at least 8 characters.';
    if (!RegExp(r'[A-Za-z]').hasMatch(value) || !RegExp(r'\d').hasMatch(value)) {
      return 'Include a letter and a number.';
    }
    return null;
  }
}
