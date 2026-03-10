import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/app_localizations.dart';
import '../models/qr_record.dart';
import '../utils/app_motion.dart';
import '../widgets/background_screen_widget.dart';

class ShowQrScreen extends StatefulWidget {
  final QRRecord? record;
  const ShowQrScreen({super.key, this.record});

  @override
  State<ShowQrScreen> createState() => _ShowQrScreenState();
}

class _ShowQrScreenState extends State<ShowQrScreen>
    with WidgetsBindingObserver {
  static const Duration _staleShareFileMaxAge = Duration(hours: 24);
  final _qrKey = GlobalKey();
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_cleanupStaleQrShareFiles());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_cleanupStaleQrShareFiles());
    }
  }

  Future<void> _cleanupStaleQrShareFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final shareDir = Directory('${tempDir.path}/qr_share');
      if (!await shareDir.exists()) return;

      final cutoff = DateTime.now().subtract(_staleShareFileMaxAge);
      await for (final entity in shareDir.list(followLinks: false)) {
        if (entity is! File) continue;
        final fileName = entity.uri.pathSegments.last;
        if (!_isShareTempQrFile(fileName)) continue;
        final modifiedAt = (await entity.stat()).modified;
        if (modifiedAt.isAfter(cutoff)) continue;
        try {
          await entity.delete();
        } catch (e, st) {
          dev.log(
            '[ShowQrScreen] stale temp file cleanup failed: $e',
            stackTrace: st,
            name: 'ShowQrScreen',
          );
        }
      }
    } catch (e, st) {
      dev.log(
        '[ShowQrScreen] temp file cleanup failed: $e',
        stackTrace: st,
        name: 'ShowQrScreen',
      );
    }
  }

  bool _isShareTempQrFile(String fileName) {
    final normalized = fileName.toLowerCase();
    return normalized.endsWith('_qr.png') ||
        RegExp(r'_qr_\d+\.png$').hasMatch(normalized);
  }

  String _tempShareFileName(String qrType) {
    final sanitizedType = qrType
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    final safeType = sanitizedType.isEmpty ? 'qr' : sanitizedType;
    return '${safeType}_qr_${DateTime.now().microsecondsSinceEpoch}.png';
  }

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

  Future<void> _shareQrImage(String qrType) async {
    try {
      final bytes = await _captureQrImage();
      if (bytes == null) return;
      final tempDir = await getTemporaryDirectory();
      final shareDir = Directory('${tempDir.path}/qr_share');
      if (!await shareDir.exists()) {
        await shareDir.create(recursive: true);
      }
      final file = File('${shareDir.path}/${_tempShareFileName(qrType)}');
      await file.writeAsBytes(bytes);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          fileNameOverrides: ['${qrType}_qr.png'],
        ),
      );
    } catch (e, st) {
      dev.log('[ShowQrScreen] share failed: $e',
          stackTrace: st, name: 'ShowQrScreen');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).failedToShare)),
      );
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
      setState(() => _copied = true);
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (mounted) setState(() => _copied = false);
      });
    } catch (e, st) {
      dev.log('[ShowQrScreen] copy failed: $e',
          stackTrace: st, name: 'ShowQrScreen');
    }
  }

  @override
  Widget build(BuildContext context) {
    final motion = AppMotion.of(context);
    final l10n = AppLocalizations.of(context);
    final record = widget.record;
    final data = record?.data ?? '';
    final qrType = record?.qrType ?? 'Unknown';

    return BackgroundScreenWidget(
      screenTitle: l10n.qrCode,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: ListView(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xff3C3C3C),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xff000000).withValues(alpha: 0.25),
                    offset: const Offset(0, 4),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          qrType[0].toUpperCase() + qrType.substring(1),
                          style: const TextStyle(
                            color: Color(0xffD9D9D9),
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          data,
                          style: const TextStyle(
                            color: Color(0xffA4A4A4),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
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
            const SizedBox(height: 40),
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
                  border: Border.all(
                    color: const Color(0xffFDB623),
                    width: 4,
                  ),
                ),
                child: data.isNotEmpty
                    ? RepaintBoundary(
                        key: _qrKey,
                        child: QrImageView(
                          data: data,
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                      )
                    : Center(
                        child: Text(l10n.noData),
                      ),
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
            const SizedBox(height: 60),
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
                const SizedBox(width: 40),
                _ActionButton(
                  icon: Icons.share_rounded,
                  label: l10n.shareBtn,
                  onTap: () {
                    AppHaptics.light(context);
                    AppSounds.click();
                    _shareQrImage(qrType);
                  },
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
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Action button with press scale + confirmed (green) state
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
        if (!motion.reduceMotion) _press.forward();
      },
      onTapUp: (_) {
        if (!motion.reduceMotion) _press.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        if (!motion.reduceMotion) _press.reverse();
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
