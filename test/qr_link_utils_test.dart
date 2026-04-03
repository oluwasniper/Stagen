import 'package:flutter_test/flutter_test.dart';
import 'package:scagen/utils/qr_link_utils.dart';

void main() {
  group('tryParseSafeExternalActionUri', () {
    test('accepts normal https URLs', () {
      final uri = tryParseSafeExternalActionUri('https://example.com/path');

      expect(uri, isNotNull);
      expect(uri!.host, 'example.com');
    });

    test('rejects credential-bearing URLs', () {
      expect(
        tryParseSafeExternalActionUri('https://user@example.com'),
        isNull,
      );
    });

    test('rejects tel URIs with an authority section', () {
      expect(
        tryParseSafeExternalActionUri('tel://evil.example'),
        isNull,
      );
    });
  });

  group('QR payload builders', () {
    test('canonicalizes bare website domains to https', () {
      expect(
        buildWebsiteQrPayload('example.com/login'),
        'https://example.com/login',
      );
    });

    test('rejects non-http website schemes', () {
      expect(buildWebsiteQrPayload('javascript:alert(1)'), isEmpty);
    });

    test('normalizes whatsapp numbers to digits only', () {
      expect(
        buildWhatsAppQrPayload('+1 (415) 555-0123'),
        'https://wa.me/14155550123',
      );
    });

    test('accepts whatsapp links and canonicalizes them', () {
      expect(
        buildWhatsAppQrPayload('https://wa.me/14155550123'),
        'https://wa.me/14155550123',
      );
    });

    test('accepts twitter profile URLs and canonicalizes host', () {
      expect(
        buildTwitterQrPayload('https://x.com/example_user'),
        'https://twitter.com/example_user',
      );
    });

    test('encodes SMS bodies safely', () {
      expect(
        buildSmsQrPayload(
          numberRaw: '+14155550123',
          messageRaw: 'hello there',
        ),
        'sms:+14155550123?body=hello+there',
      );
    });

    test('rejects out-of-range geo coordinates', () {
      expect(
        buildGeoQrPayload(latitudeRaw: '91', longitudeRaw: '10'),
        isEmpty,
      );
    });

    test('sanitizes share file stems', () {
      expect(
        sanitizeShareFileStem('Team QR / April 2026', fallback: 'qr'),
        'team_qr_april_2026',
      );
    });
  });
}
