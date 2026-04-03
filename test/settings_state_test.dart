import 'package:flutter_test/flutter_test.dart';
import 'package:scagen/providers/settings_provider.dart';

void main() {
  test('SettingsState defaults to vibrate/beep enabled and analytics disabled',
      () {
    const state = SettingsState();

    expect(state.vibrate, isTrue);
    expect(state.beep, isTrue);
    expect(state.analyticsEnabled, isFalse);
  });

  test('SettingsState.copyWith updates only provided fields', () {
    const state =
        SettingsState(vibrate: false, beep: false, analyticsEnabled: false);
    final updated = state.copyWith(vibrate: true);

    expect(updated.vibrate, isTrue);
    expect(updated.beep, isFalse);
    expect(updated.analyticsEnabled, isFalse);
  });
}
