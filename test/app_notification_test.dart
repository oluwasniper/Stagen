import 'package:flutter_test/flutter_test.dart';
import 'package:scagen/models/app_notification.dart';

void main() {
  group('AppNotification.fromAppwrite', () {
    test('sanitizes oversized text fields and normalizes whitespace', () {
      final notification = AppNotification.fromAppwrite({
        r'$id': 'doc1',
        'title': '  Hello   world  ${'x' * 200}',
        'body': 'Line 1\r\n\r\nLine 2 ${'y' * 600}',
        'actionLabel': '  Open   now  ',
        'actionRoute': '/notifications?x=${'a' * 400}',
        'createdAt': '2026-03-31T10:00:00.000Z',
      });

      expect(notification.title.length, lessThanOrEqualTo(120));
      expect(notification.title.startsWith('Hello world'), isTrue);
      expect(notification.body.length, lessThanOrEqualTo(500));
      expect(notification.body.startsWith('Line 1 Line 2'), isTrue);
      expect(notification.actionLabel, 'Open now');
      expect(notification.actionRoute!.length, lessThanOrEqualTo(256));
    });

    test('drops empty action route after sanitization', () {
      final notification = AppNotification.fromAppwrite({
        r'$id': 'doc2',
        'title': 'Title',
        'body': 'Body',
        'actionRoute': '   ',
      });

      expect(notification.actionRoute, isNull);
    });
  });
}
