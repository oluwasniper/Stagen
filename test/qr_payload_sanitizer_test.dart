import 'package:flutter_test/flutter_test.dart';
import 'package:scagen/utils/qr_payload_sanitizer.dart';

void main() {
  group('QR payload sanitizers', () {
    test('normalizeSingleLineQrField strips line breaks and trims', () {
      expect(
        normalizeSingleLineQrField('  one\r\ntwo\nthree  '),
        'one two three',
      );
    });

    test('escapeWifiQrField escapes QR delimiter characters', () {
      expect(
        escapeWifiQrField(r'Cafe\Lobby;Guest,1:2'),
        r'Cafe\\Lobby\;Guest\,1\:2',
      );
    });

    test('escapeWifiQrField collapses newlines to spaces', () {
      expect(
        escapeWifiQrField('Floor 1\nGuest'),
        'Floor 1 Guest',
      );
    });

    test('escapeVCardQrText escapes separators and line breaks', () {
      expect(
        escapeVCardQrText('Doe, John;\nCEO\\Founder'),
        r'Doe\, John\;\nCEO\\Founder',
      );
    });
  });
}
