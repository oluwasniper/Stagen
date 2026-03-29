import 'package:flutter_test/flutter_test.dart';
import 'package:scagen/models/qr_record.dart';

void main() {
  test('QRRecord serializes and deserializes correctly', () {
    final createdAt = DateTime.parse('2026-01-01T10:00:00.000Z');
    final record = QRRecord(
      id: 'rec_1',
      data: 'https://example.com',
      type: 'generated',
      qrType: 'website',
      label: 'Website',
      userId: 'user_1',
      createdAt: createdAt,
    );

    expect(record.isPendingSync, false);

    final json = record.toJson();
    final decoded = QRRecord.fromJson({...json, '\$id': record.id});

    expect(decoded.id, 'rec_1');
    expect(decoded.data, 'https://example.com');
    expect(decoded.type, 'generated');
    expect(decoded.qrType, 'website');
    expect(decoded.label, 'Website');
    expect(decoded.userId, 'user_1');
    expect(decoded.createdAt, createdAt);
    expect(decoded.isPendingSync, false);
  });
}
