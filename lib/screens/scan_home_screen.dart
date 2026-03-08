import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../l10n/app_localizations.dart';
import '../models/qr_record.dart';
import '../providers/qr_providers.dart';
import '../providers/settings_provider.dart';
import '../services/telemetry_service.dart';
import '../utils/app_router.dart';
import '../utils/qr_isolate.dart';
import '../utils/route/app_path.dart';

class ScanHomeScreen extends ConsumerStatefulWidget {
  const ScanHomeScreen({super.key});

  @override
  ConsumerState<ScanHomeScreen> createState() => _ScanHomeScreenState();
}

class _ScanHomeScreenState extends ConsumerState<ScanHomeScreen>
    with TickerProviderStateMixin {
  final MobileScannerController controller = MobileScannerController();
  final ImagePicker _imagePicker = ImagePicker();

  bool _hasNavigated = false;
  bool _didSucceed = false;

  // Scanning line animation
  late AnimationController _scanLineController;
  late Animation<double> _scanLineAnimation;

  // Success pulse animation
  late AnimationController _pulseController;
  late Animation<double> _pulseScale;

  // Corner bracket subtle breathing
  late AnimationController _breatheController;
  late Animation<double> _breatheAnimation;

  @override
  void initState() {
    super.initState();

    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _scanLineAnimation = CurvedAnimation(
      parent: _scanLineController,
      curve: Curves.easeInOut,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _pulseScale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _breatheAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    _scanLineController.dispose();
    _pulseController.dispose();
    _breatheController.dispose();
    super.dispose();
  }

  Future<void> _handleScannedData(String data) async {
    if (_hasNavigated) return;
    setState(() {
      _hasNavigated = true;
      _didSucceed = true;
    });

    final settings = ref.read(settingsProvider);
    if (settings.vibrate) HapticFeedback.mediumImpact();
    if (settings.beep) SystemSound.play(SystemSoundType.click);

    // Play success pulse
    _pulseController.forward(from: 0);

    // Classify off the main thread — no jank during scan detection
    final classification = await QRIsolate.classify(data);

    ref.read(telemetryServiceProvider).track(
      TelemetryEvents.qrScanned,
      properties: {'content_type': classification.qrTypeString},
    );

    ref.read(scannedQRDataProvider.notifier).state = data;

    final record = QRRecord(
      data: data,
      type: 'scanned',
      qrType: classification.qrTypeString,
      label: null,
    );
    ref.read(scannedHistoryProvider.notifier).addRecord(record);

    // Brief delay so user sees the success flash
    await Future.delayed(const Duration(milliseconds: 350));

    try {
      await controller.stop();
      await AppGoRouter.router.push(AppPath.scannedQRResult);
    } finally {
      if (mounted) {
        setState(() {
          _hasNavigated = false;
          _didSucceed = false;
        });
        _pulseController.reset();
        await controller.start();
      } else {
        _hasNavigated = false;
        _didSucceed = false;
      }
    }
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_hasNavigated) return;
    final barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      await _handleScannedData(barcodes.first.rawValue!);
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final capture = await controller.analyzeImage(image.path);
      String? code;
      if (capture != null && capture.barcodes.isNotEmpty) {
        code = capture.barcodes.first.rawValue;
      }
      if (code == null || code.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).noQrFoundInImage),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xff333333),
          ),
        );
        return;
      }
      await _handleScannedData(code);
    } catch (e, st) {
      dev.log('[ScanHomeScreen] gallery scan failed: $e', stackTrace: st);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scanWindowSize = size.width - 80.0;
    final scanWindowTop = (size.height - scanWindowSize) / 2 - 40;

    final scanRect = Rect.fromLTWH(
      40,
      scanWindowTop,
      scanWindowSize,
      scanWindowSize,
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera feed
        MobileScanner(
          controller: controller,
          onDetect: _onDetect,
          fit: BoxFit.cover,
          scanWindow: scanRect,
        ),

        // Dark vignette overlay with cutout
        _ScanOverlay(
          scanRect: scanRect,
          didSucceed: _didSucceed,
        ),

        // Animated corner brackets
        AnimatedBuilder(
          animation: _breatheAnimation,
          builder: (context, _) {
            return _ScanCornerBrackets(
              scanRect: scanRect,
              didSucceed: _didSucceed,
              breathe: _breatheAnimation.value,
            );
          },
        ),

        // Scanning line
        if (!_didSucceed)
          AnimatedBuilder(
            animation: _scanLineAnimation,
            builder: (context, _) {
              return Positioned(
                left: scanRect.left + 16,
                top: scanRect.top +
                    (_scanLineAnimation.value * (scanRect.height - 4)),
                child: Container(
                  width: scanRect.width - 32,
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Colors.transparent,
                        Color(0xffFDB623),
                        Color(0xffFDB623),
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.2, 0.8, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xffFDB623).withValues(alpha: 0.6),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

        // Success pulse ring
        if (_didSucceed)
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) {
              return Positioned(
                left: scanRect.left - 8 * _pulseScale.value,
                top: scanRect.top - 8 * _pulseScale.value,
                child: Opacity(
                  opacity: (1.0 - _pulseController.value).clamp(0.0, 1.0),
                  child: Container(
                    width: (scanRect.width + 16) * _pulseScale.value,
                    height: (scanRect.height + 16) * _pulseScale.value,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20 * _pulseScale.value),
                      border: Border.all(
                        color: const Color(0xff4CAF50),
                        width: 3,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

        // Top control bar
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 20,
          right: 20,
          child: _ScanControlBar(
            controller: controller,
            onGallery: _pickFromGallery,
          ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.5, end: 0, curve: Curves.easeOut),
        ),

        // Bottom hint label
        Positioned(
          left: 20,
          right: 20,
          bottom: scanRect.top > 200
              ? scanRect.top - 60
              : scanRect.bottom + 24,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _didSucceed
                    ? '✓  QR Code Detected'
                    : AppLocalizations.of(context).scan,
                style: TextStyle(
                  color: _didSucceed
                      ? const Color(0xff4CAF50)
                      : Colors.white.withValues(alpha: 0.85),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ).animate(key: ValueKey(_didSucceed)).fadeIn(duration: 200.ms),
          ),
        ),
      ],
    );
  }
}

/// Dark overlay with a transparent rectangular cutout for the scan window.
class _ScanOverlay extends StatelessWidget {
  final Rect scanRect;
  final bool didSucceed;

  const _ScanOverlay({required this.scanRect, required this.didSucceed});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: CustomPaint(
        painter: _OverlayPainter(
          scanRect: scanRect,
          dimColor:
              didSucceed ? Colors.black.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.55),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final Rect scanRect;
  final Color dimColor;

  _OverlayPainter({required this.scanRect, required this.dimColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = dimColor;
    final fullRect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(scanRect, const Radius.circular(16));

    final path = Path()
      ..addRect(fullRect)
      ..addRRect(rrect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_OverlayPainter old) =>
      old.scanRect != scanRect || old.dimColor != dimColor;
}

/// Animated corner bracket decorations.
class _ScanCornerBrackets extends StatelessWidget {
  final Rect scanRect;
  final bool didSucceed;
  final double breathe;

  const _ScanCornerBrackets({
    required this.scanRect,
    required this.didSucceed,
    required this.breathe,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BracketPainter(
        scanRect: scanRect,
        color: didSucceed ? const Color(0xff4CAF50) : Color.lerp(
          const Color(0xffFDB623).withValues(alpha: 0.7),
          const Color(0xffFDB623),
          breathe,
        )!,
        strokeWidth: 3.5,
        bracketLength: 28,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _BracketPainter extends CustomPainter {
  final Rect scanRect;
  final Color color;
  final double strokeWidth;
  final double bracketLength;

  _BracketPainter({
    required this.scanRect,
    required this.color,
    required this.strokeWidth,
    required this.bracketLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final r = scanRect;
    final l = bracketLength;
    final radius = 16.0;

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(r.left, r.top + l)
        ..lineTo(r.left, r.top + radius)
        ..quadraticBezierTo(r.left, r.top, r.left + radius, r.top)
        ..lineTo(r.left + l, r.top),
      paint,
    );
    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(r.right - l, r.top)
        ..lineTo(r.right - radius, r.top)
        ..quadraticBezierTo(r.right, r.top, r.right, r.top + radius)
        ..lineTo(r.right, r.top + l),
      paint,
    );
    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(r.left, r.bottom - l)
        ..lineTo(r.left, r.bottom - radius)
        ..quadraticBezierTo(r.left, r.bottom, r.left + radius, r.bottom)
        ..lineTo(r.left + l, r.bottom),
      paint,
    );
    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(r.right - l, r.bottom)
        ..lineTo(r.right - radius, r.bottom)
        ..quadraticBezierTo(r.right, r.bottom, r.right, r.bottom - radius)
        ..lineTo(r.right, r.bottom - l),
      paint,
    );
  }

  @override
  bool shouldRepaint(_BracketPainter old) =>
      old.scanRect != scanRect ||
      old.color != color ||
      old.strokeWidth != strokeWidth;
}

class _ScanControlBar extends ConsumerWidget {
  final MobileScannerController controller;
  final VoidCallback onGallery;

  const _ScanControlBar({
    required this.controller,
    required this.onGallery,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ControlButton(
              icon: Icons.photo_library_rounded,
              onTap: () {
                HapticFeedback.lightImpact();
                onGallery();
              },
            ),
            Container(
              width: 0.5,
              height: 28,
              color: Colors.white.withValues(alpha: 0.15),
            ),
            ValueListenableBuilder(
              valueListenable: controller,
              builder: (context, state, _) {
                final isOn = state.torchState == TorchState.on;
                return _ControlButton(
                  icon: isOn
                      ? Icons.flash_on_rounded
                      : Icons.flash_off_rounded,
                  color: isOn ? const Color(0xffFDB623) : Colors.white,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    controller.toggleTorch();
                    ref
                        .read(telemetryServiceProvider)
                        .track(TelemetryEvents.scannerTorchToggled);
                  },
                );
              },
            ),
            Container(
              width: 0.5,
              height: 28,
              color: Colors.white.withValues(alpha: 0.15),
            ),
            _ControlButton(
              icon: Icons.flip_camera_ios_rounded,
              onTap: () {
                HapticFeedback.lightImpact();
                controller.switchCamera();
                ref
                    .read(telemetryServiceProvider)
                    .track(TelemetryEvents.scannerCameraSwitched);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    this.color = Colors.white,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80,
        height: 52,
        child: Center(
          child: Icon(icon, color: color, size: 24),
        ),
      ),
    );
  }
}
