import 'package:flutter_test/flutter_test.dart';
import 'package:ugcult/features/auth/utils/egyptian_phone_formatter.dart';

void main() {
  group('EgyptianPhoneUtils Validation Tests', () {
    test('accepts valid 11-digit local Egyptian mobile numbers', () {
      expect(EgyptianPhoneUtils.isValid('01012345678'), isTrue); // Vodafone
      expect(EgyptianPhoneUtils.isValid('01198765432'), isTrue); // Etisalat
      expect(EgyptianPhoneUtils.isValid('01234567890'), isTrue); // Orange
      expect(EgyptianPhoneUtils.isValid('01555555555'), isTrue); // WE
    });

    test('accepts valid E.164 formatted numbers', () {
      expect(EgyptianPhoneUtils.isValid('+201012345678'), isTrue);
      expect(EgyptianPhoneUtils.isValid('+201198765432'), isTrue);
      expect(EgyptianPhoneUtils.isValid('+201234567890'), isTrue);
      expect(EgyptianPhoneUtils.isValid('+201555555555'), isTrue);
    });

    test('accepts numbers with spaces or hyphens', () {
      expect(EgyptianPhoneUtils.isValid('010 1234 5678'), isTrue);
      expect(EgyptianPhoneUtils.isValid('+20 10-1234-5678'), isTrue);
      expect(EgyptianPhoneUtils.isValid('(012) 3456 7890'), isTrue);
    });

    test('rejects invalid numbers', () {
      expect(EgyptianPhoneUtils.isValid('01312345678'), isFalse); // invalid prefix 013
      expect(EgyptianPhoneUtils.isValid('01412345678'), isFalse); // invalid prefix 014
      expect(EgyptianPhoneUtils.isValid('0101234567'), isFalse);  // too short (10 digits)
      expect(EgyptianPhoneUtils.isValid('010123456789'), isFalse); // too long (12 digits)
      expect(EgyptianPhoneUtils.isValid('abcdefghijk'), isFalse);
      expect(EgyptianPhoneUtils.isValid('+14155552671'), isFalse); // US number
    });

    test('normalizes to E.164 correctly', () {
      expect(EgyptianPhoneUtils.toE164('01012345678'), equals('+201012345678'));
      expect(EgyptianPhoneUtils.toE164('+201198765432'), equals('+201198765432'));
      expect(EgyptianPhoneUtils.toE164('1234567890'), equals('+201234567890'));
      expect(EgyptianPhoneUtils.toE164('015 5555 5555'), equals('+201555555555'));
    });

    test('formats for display correctly', () {
      expect(EgyptianPhoneUtils.formatDisplay('01012345678'), equals('010 1234 5678'));
      expect(EgyptianPhoneUtils.formatDisplay('+201198765432'), equals('011 9876 5432'));
    });

    test('identifies carrier correctly', () {
      expect(EgyptianPhoneUtils.getCarrier('01012345678'), equals('Vodafone Egypt'));
      expect(EgyptianPhoneUtils.getCarrier('01112345678'), equals('Etisalat Egypt'));
      expect(EgyptianPhoneUtils.getCarrier('01212345678'), equals('Orange Egypt'));
      expect(EgyptianPhoneUtils.getCarrier('01512345678'), equals('WE (Telecom Egypt)'));
    });
  });
}
