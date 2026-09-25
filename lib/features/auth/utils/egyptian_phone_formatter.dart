/// Utility class for validating and normalizing Egyptian mobile numbers.
/// Valid prefixes: 010 (Vodafone), 011 (Etisalat), 012 (Orange), 015 (WE).
abstract final class EgyptianPhoneUtils {
  /// Regular expression for standard 11-digit Egyptian mobile number: 01[0125]xxxxxxxx
  static final RegExp _egyptianMobileRegex = RegExp(r'^01[0125]\d{8}$');

  /// Regular expression for normalized E.164 Egyptian mobile number: +201[0125]xxxxxxxx
  static final RegExp _e164Regex = RegExp(r'^\+201[0125]\d{8}$');

  /// Validates whether the given string is a valid Egyptian mobile number
  /// (accepts both local '01012345678' and E.164 '+201012345678' formats).
  static bool isValid(String raw) {
    final cleaned = clean(raw);
    if (_egyptianMobileRegex.hasMatch(cleaned)) return true;
    if (_e164Regex.hasMatch(cleaned)) return true;
    return false;
  }

  /// Removes all whitespace, dashes, and parentheses
  static String clean(String raw) {
    return raw.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  }

  /// Normalizes an Egyptian mobile number to E.164 format: `+201xxxxxxxxx`
  /// Throws [FormatException] if number cannot be normalized.
  static String toE164(String raw) {
    final cleaned = clean(raw);
    if (_e164Regex.hasMatch(cleaned)) {
      return cleaned;
    }
    if (_egyptianMobileRegex.hasMatch(cleaned)) {
      // Remove leading 0 and prepend +20
      return '+20${cleaned.substring(1)}';
    }
    // If user enters 10 digits starting with 1[0125] (without leading 0)
    if (RegExp(r'^1[0125]\d{8}$').hasMatch(cleaned)) {
      return '+20$cleaned';
    }
    throw FormatException('Invalid Egyptian mobile number format: $raw');
  }

  /// Formats for local Egyptian display: `010 1234 5678`
  static String formatDisplay(String raw) {
    try {
      final e164 = toE164(raw);
      // e164 is +201012345678
      final local = '0${e164.substring(3)}'; // 01012345678
      if (local.length == 11) {
        return '${local.substring(0, 3)} ${local.substring(3, 7)} ${local.substring(7)}';
      }
      return local;
    } catch (_) {
      return raw;
    }
  }

  /// Returns the network telecom carrier name in Egypt
  static String? getCarrier(String raw) {
    try {
      final e164 = toE164(raw);
      final prefix = e164.substring(3, 5); // e.g. "10", "11", "12", "15"
      return switch (prefix) {
        '10' => 'Vodafone Egypt',
        '11' => 'Etisalat Egypt',
        '12' => 'Orange Egypt',
        '15' => 'WE (Telecom Egypt)',
        _ => null,
      };
    } catch (_) {
      return null;
    }
  }
}
