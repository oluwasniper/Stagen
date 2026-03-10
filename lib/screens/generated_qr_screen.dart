import 'dart:developer' as dev;
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/app_localizations.dart';
import '../providers/qr_providers.dart';
import '../services/telemetry_service.dart';
import '../utils/app_motion.dart';
import '../utils/app_router.dart';
import '../utils/route/app_path.dart';
import '../widgets/background_screen_widget.dart';

class GeneratedQRScreen extends ConsumerStatefulWidget {
  const GeneratedQRScreen({super.key});

  @override
  ConsumerState<GeneratedQRScreen> createState() => _GeneratedQRScreenState();
}

class _GeneratedQRScreenState extends ConsumerState<GeneratedQRScreen> {
  final _qrKey = GlobalKey();
  bool _copied = false;

  Future<Uint8List?> _captureQrImage() async {
    final boundary =
        _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 3.0);
    try {
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  }

  Future<void> _copyQrImage() async {
    if (_copied) return;
    try {
      final bytes = await _captureQrImage();
      if (bytes == null) return;
      await Pasteboard.writeImage(bytes);
      if (!mounted) return;
      AppHaptics.medium(context);
      AppSounds.click();
      ref.read(telemetryServiceProvider).track(
        TelemetryEvents.qrCopied,
        properties: {'source': 'generated'},
      );
      setState(() => _copied = true);
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (mounted) setState(() => _copied = false);
      });
    } catch (e, st) {
      dev.log('[GeneratedQRScreen] copy failed: $e',
          stackTrace: st, name: 'GeneratedQRScreen');
    }
  }

  Future<void> _shareQrImage(String label) async {
    try {
      final bytes = await _captureQrImage();
      if (bytes == null) return;
      final tempDir = await getTemporaryDirectory();
      final shareDir = Directory('${tempDir.path}/qr_share');
      if (!await shareDir.exists()) {
        await shareDir.create(recursive: true);
      }
      final file = File(
        '${shareDir.path}/qr_code_${DateTime.now().microsecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          fileNameOverrides: ['${label}_qr.png'],
        ),
      );
      if (mounted) {
        AppHaptics.light(context);
      }
      AppSounds.click();
      ref.read(telemetryServiceProvider).track(
        TelemetryEvents.qrShared,
        properties: {'source': 'generated'},
      );
    } catch (e, st) {
      dev.log('[GeneratedQRScreen] share failed: $e',
          stackTrace: st, name: 'GeneratedQRScreen');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final qrData = ref.watch(generatedQRDataProvider) ?? '';
    final label = ref.watch(generatedQRLabelProvider) ?? l10n.qrCode;
    final qrType = ref.watch(generatedQRTypeProvider) ?? '';
    final motion = AppMotion.of(context);

    return BackgroundScreenWidget(
      screenTitle: label,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            const SizedBox(height: 8),

            // Data info card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xff3C3C3C),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      qrType.isNotEmpty
                          ? qrType[0].toUpperCase() + qrType.substring(1)
                          : l10n.generatedLabel,
                      style: const TextStyle(
                        color: Color(0xffFDB623),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      qrData,
                      style: const TextStyle(
                        color: Color(0xffD9D9D9),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(duration: motion.duration(AppMotion.medium))
                .slideY(
                  begin: motion.reduceMotion ? 0 : -0.1,
                  end: 0,
                  duration: motion.duration(AppMotion.medium),
                  curve: motion.curve(AppMotion.enter),
                ),

            const SizedBox(height: 36),

            // QR code
            Center(
              child: Container(
                height: 225,
                width: 225,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xffF5F5F5).withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      offset: const Offset(0, 6),
                      blurRadius: 16,
                    ),
                  ],
                  border: Border.all(color: const Color(0xffFDB623), width: 4),
                ),
                child: qrData.isNotEmpty
                    ? RepaintBoundary(
                        key: _qrKey,
                        child: QrImageView(
                          data: qrData,
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                      )
                    : Center(child: Text(l10n.noData)),
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1, 1),
                  delay: motion.delay(AppMotion.fast),
                  duration: motion.duration(AppMotion.slow),
                  curve: motion.curve(AppMotion.spring),
                )
                .fadeIn(
                  delay: motion.delay(AppMotion.fast),
                  duration: motion.duration(AppMotion.medium),
                ),

            const SizedBox(height: 52),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ActionButton(
                  icon: _copied ? Icons.check_rounded : Icons.copy_rounded,
                  label:
                      _copied ? l10n.snackbarCopiedToClipboard : l10n.copyBtn,
                  confirmed: _copied,
                  onTap: _copyQrImage,
                ),
                const SizedBox(width: 32),
                _ActionButton(
                  icon: Icons.share_rounded,
                  label: l10n.shareBtn,
                  onTap: () => _shareQrImage(label),
                ),
              ],
            )
                .animate()
                .fadeIn(
                  delay: motion.delay(AppMotion.slow),
                  duration: motion.duration(AppMotion.medium),
                )
                .slideY(
                  begin: motion.reduceMotion ? 0 : 0.2,
                  end: 0,
                  delay: motion.delay(AppMotion.slow),
                  duration: motion.duration(AppMotion.medium),
                  curve: motion.curve(AppMotion.enter),
                ),

            const SizedBox(height: 32),

            // Done / close button
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () {
                    AppHaptics.light(context);
                    AppSounds.click();
                    AppGoRouter.router.go(AppPath.generateHome);
                  },
                  icon: const Icon(Icons.grid_view_rounded, size: 20),
                  label: Text(l10n.backToGenerate),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xffFDB623),
                    side:
                        const BorderSide(color: Color(0xffFDB623), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(
                  delay: motion.delay(const Duration(milliseconds: 650)),
                  duration: motion.duration(const Duration(milliseconds: 350)),
                ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared action button with press animation + confirmed state
// ---------------------------------------------------------------------------

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool confirmed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.confirmed = false,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _press;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _press, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final motion = AppMotion.of(context);

    return GestureDetector(
      onTapDown: (_) {
        if (!motion.reduceMotion) {
          _press.forward();
        }
      },
      onTapUp: (_) {
        if (!motion.reduceMotion) {
          _press.reverse();
        }
        widget.onTap();
      },
      onTapCancel: () {
        if (!motion.reduceMotion) {
          _press.reverse();
        }
      },
      child: AnimatedBuilder(
        animation: _press,
        builder: (_, child) => Transform.scale(
          scale: motion.reduceMotion ? 1.0 : _scale.value,
          child: child,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: motion.duration(AppMotion.fast),
              curve: motion.curve(AppMotion.standard),
              height: 54,
              width: 54,
              decoration: BoxDecoration(
                color: widget.confirmed
                    ? const Color(0xff4CAF50)
                    : const Color(0xffFDB623),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: (widget.confirmed
                            ? const Color(0xff4CAF50)
                            : const Color(0xffFDB623))
                        .withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: motion.duration(AppMotion.fast),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: child,
                ),
                child: Icon(
                  widget.icon,
                  key: ValueKey(widget.icon),
                  color:
                      widget.confirmed ? Colors.white : const Color(0xff1A1A1A),
                  size: 22,
                ),
              ),
            ),
            const SizedBox(height: 8),
            AnimatedDefaultTextStyle(
              duration: motion.duration(AppMotion.fast),
              style: TextStyle(
                color: widget.confirmed
                    ? const Color(0xff4CAF50)
                    : const Color(0xffD9D9D9),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              child: Text(
                widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
