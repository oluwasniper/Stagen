import 'dart:async';
import 'dart:developer' as dev;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider =
    StateNotifierProvider<ConnectivityNotifier, bool>((ref) {
  return ConnectivityNotifier();
});

class ConnectivityNotifier extends StateNotifier<bool> {
  late final StreamSubscription<List<ConnectivityResult>> _sub;

  ConnectivityNotifier() : super(false) {
    _sub = Connectivity().onConnectivityChanged.listen(_onChanged);
    unawaited(_initConnectivity());
  }

  Future<void> _initConnectivity() async {
    try {
      final results = await Connectivity().checkConnectivity();
      _onChanged(results);
    } catch (error, stackTrace) {
      dev.log(
        '[ConnectivityNotifier] initial check failed: $error',
        stackTrace: stackTrace,
        name: 'ConnectivityNotifier',
      );
      _onChanged(const [ConnectivityResult.none]);
    }
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
