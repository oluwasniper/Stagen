import 'dart:developer' as dev;
import 'dart:ui' show FrameTiming;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'telemetry_service.dart';

/// Runtime performance instrumentation:
/// - tunes image cache limits for smoother scrolling
/// - monitors frame timings and reports jank windows
/// - reacts to memory pressure by clearing image caches
class AppPerformanceService with WidgetsBindingObserver {
  AppPerformanceService({
    required TelemetryService Function() telemetryReader,
  }) : _telemetryReader = telemetryReader;

  final TelemetryService Function() _telemetryReader;

  bool _started = false;
  int _sampledFrames = 0;
  int _slowFrames = 0;

  static const int _windowSize = 180;
  static const double _slowFrameThresholdMs = 16.7;

  void start() {
    if (_started) return;
    _started = true;
    _configureImageCache();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addTimingsCallback(_onFrameTimings);
  }

  void stop() {
    if (!_started) return;
    _started = false;
    WidgetsBinding.instance.removeObserver(this);
    WidgetsBinding.instance.removeTimingsCallback(_onFrameTimings);
  }

  void _configureImageCache() {
    final cache = PaintingBinding.instance.imageCache;
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android) {
      cache.maximumSize = 700;
      cache.maximumSizeBytes = 140 << 20; // 140 MB
      return;
    }

    cache.maximumSize = 1200;
    cache.maximumSizeBytes = 220 << 20; // 220 MB
  }

  void _onFrameTimings(List<FrameTiming> timings) {
    if (!_started || timings.isEmpty) return;

    for (final timing in timings) {
      _sampledFrames += 1;
      final totalMs =
          timing.totalSpan.inMicroseconds / Duration.microsecondsPerMillisecond;
      if (totalMs > _slowFrameThresholdMs) {
        _slowFrames += 1;
      }
    }

    if (_sampledFrames < _windowSize) return;

    final jankRatio = _slowFrames / _sampledFrames;
    if (jankRatio >= 0.12) {
      _telemetryReader().track(
        TelemetryEvents.frameJankWindow,
        properties: {
          'sampled_frames': _sampledFrames,
          'slow_frames': _slowFrames,
          'slow_ratio': double.parse(jankRatio.toStringAsFixed(3)),
        },
      );
    }

    _sampledFrames = 0;
    _slowFrames = 0;
  }

  @override
  void didHaveMemoryPressure() {
    final cache = PaintingBinding.instance.imageCache;
    final clearedEntries = cache.currentSize;
    final clearedBytes = cache.currentSizeBytes;

    cache.clear();
    cache.clearLiveImages();

    dev.log(
      '[AppPerformanceService] memory pressure handled, '
      'cleared $clearedEntries images ($clearedBytes bytes)',
      name: 'AppPerformanceService',
    );

    _telemetryReader().track(
      TelemetryEvents.memoryPressureHandled,
      properties: {
        'cleared_entries': clearedEntries,
        'cleared_bytes': clearedBytes,
      },
    );
  }
}
