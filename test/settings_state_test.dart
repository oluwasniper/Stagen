import 'package:flutter_test/flutter_test.dart';
import 'package:revolutionary_stuff/providers/settings_provider.dart';

void main() {
  test('SettingsState defaults to all disabled', () {
    const state = SettingsState();

    expect(state.vibrate, isFalse);
    expect(state.beep, isFalse);
    expect(state.analyticsEnabled, isFalse);
  });

  test('SettingsState.copyWith updates only provided fields', () {
    const state = SettingsState(vibrate: false, beep: false, analyticsEnabled: false);
    final updated = state.copyWith(vibrate: true);

    expect(updated.vibrate, isTrue);
    expect(updated.beep, isFalse);
    expect(updated.analyticsEnabled, isFalse);
  });
}
