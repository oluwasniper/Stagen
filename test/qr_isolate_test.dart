import 'package:flutter_test/flutter_test.dart';
import 'package:scagen/utils/qr_isolate.dart';

void main() {
  tearDownAll(() async {
    await QRIsolate.dispose();
  });

  test('QRIsolate classifies URL payloads', () async {
    await QRIsolate.prewarm();
    final result = await QRIsolate.classify('https://example.com');

    expect(result.type, QRDataType.url);
    expect(result.qrTypeString, 'url');
    expect(result.displayData, 'https://example.com');
  });

  test('QRIsolate parses WIFI SSID from payload', () async {
    final result =
        await QRIsolate.classify('WIFI:T:WPA;S:Office WiFi;P:1234;;');

    expect(result.type, QRDataType.wifi);
    expect(result.displayData, 'Office WiFi');
  });
}
