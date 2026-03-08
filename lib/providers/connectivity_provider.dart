import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider =
    StateNotifierProvider<ConnectivityNotifier, bool>((ref) {
  return ConnectivityNotifier();
});

class ConnectivityNotifier extends StateNotifier<bool> {
  late final StreamSubscription<List<ConnectivityResult>> _sub;

  ConnectivityNotifier() : super(true) {
    _sub = Connectivity().onConnectivityChanged.listen(_onChanged);
    // Check current state immediately.
    Connectivity().checkConnectivity().then(_onChanged);
  }

  void _onChanged(List<ConnectivityResult> results) {
    state = results.any((r) => r != ConnectivityResult.none);
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
