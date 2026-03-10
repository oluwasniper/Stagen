import 'package:flutter_test/flutter_test.dart';
import 'package:revolutionary_stuff/utils/external_text_classifier.dart';
import 'package:revolutionary_stuff/widgets/generate_qr_widget.dart';

void main() {
  test('classifies SMSTO payload into sms type with prefill', () {
    final result = classifyExternalText('SMSTO:+15551234567:See you at 8');

    expect(result.type, QROptionType.sms);
    expect(result.prefill['smsNumber'], '+15551234567');
    expect(result.prefill['smsMessage'], 'See you at 8');
  });

  test('classifies Telegram URL into telegram type with username prefill', () {
    final result = classifyExternalText('https://t.me/scagen_app');

    expect(result.type, QROptionType.telegram);
    expect(result.prefill['telegram'], 'scagen_app');
  });

  test('classifies LinkedIn profile URL into linkedin type', () {
    final result = classifyExternalText('https://www.linkedin.com/in/jane-doe');

    expect(result.type, QROptionType.linkedin);
    expect(result.prefill['linkedin'], 'jane-doe');
  });
}
