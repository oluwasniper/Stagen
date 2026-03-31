import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_notification.dart';
import '../providers/notification_provider.dart';
import '../services/in_app_notification_service.dart';
import '../utils/app_router.dart';
import '../utils/notification_style.dart';
import '../utils/route/app_path.dart';

/// Wraps any subtree and shows auto-dismissing notification banners on top.
///
/// Place this directly inside [MaterialApp.router]'s builder, wrapping the
/// child, so banners appear above all routes including bottom sheets and dialogs.
///
/// Usage in main.dart:
/// ```dart
/// MaterialApp.router(
///   builder: (context, child) => NotificationOverlay(child: child ?? const SizedBox()),
///   ...
/// )
/// ```
class NotificationOverlay extends ConsumerStatefulWidget {
  const NotificationOverlay({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<NotificationOverlay> createState() =>
      _NotificationOverlayState();
}

class _NotificationOverlayState extends ConsumerState<NotificationOverlay> {
  static const int _maxActiveBanners = 3;

  StreamSubscription<AppNotification>? _sub;
  final List<_BannerEntry> _active = [];

  @override
  void initState() {
    super.initState();
    _sub = InAppNotificationService.instance.bannerStream.listen(_onBanner);
  }

  void _onBanner(AppNotification notification) {
    if (!mounted) return;
    final entry = _BannerEntry(notification: notification);
    setState(() {
      _active.add(entry);
      if (_active.length > _maxActiveBanners) {
        _active.removeRange(0, _active.length - _maxActiveBanners);
      }
    });

    // Auto-dismiss after 4 seconds.
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) _dismiss(entry.id);
    });
  }

  void _dismiss(String entryId) {
    if (!mounted) return;
    setState(() => _active.removeWhere((e) => e.id == entryId));
  }

  /// Returns true only for known internal GoRouter paths.
  /// Rejects anything with a scheme (http/https/etc.) or unknown paths to
  /// prevent open-redirect attacks via server-sent notification payloads.
  bool _isAllowedRoute(String route) {
    // Must start with '/' and must not contain a scheme (no '://').
    if (!route.startsWith('/') || route.contains('://')) return false;
    // Strip any query/fragment and match against the known path prefix set.
    final path = route.split('?').first.split('#').first;
    return const {
      AppPath.home,
      AppPath.history,
      AppPath.settings,
      AppPath.generateHome,
      AppPath.generateCode,
      AppPath.notifications,
      AppPath.scannedQR,
      AppPath.generatedQR,
      AppPath.showQR,
      AppPath.historyShowQR,
      AppPath.nestedHistoryScannedQR,
      AppPath.nestedHistoryGeneratedQR,
    }.any((allowed) => path == allowed || path.startsWith('$allowed/'));
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_active.isNotEmpty)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _active.map((entry) {
                return _NotificationBanner(
                  key: ValueKey(entry.id),
                  notification: entry.notification,
                  onDismiss: () => _dismiss(entry.id),
                  onTap: () {
                    // Mark read in provider.
                    ref
                        .read(notificationProvider.notifier)
                        .markRead(entry.notification.id);
                    _dismiss(entry.id);
                    // Navigate if there's an action route.
                    // Only allow known internal routes to prevent open-redirect
                    // attacks from malicious server-sent notification payloads.
                    final route = entry.notification.actionRoute;
                    if (route != null && _isAllowedRoute(route)) {
                      AppGoRouter.router.push(route);
                    } else {
                      AppGoRouter.router.push(AppPath.notifications);
                    }
                  },
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class _BannerEntry {
  _BannerEntry({required this.notification}) : id = (_nextId++).toString();

  static int _nextId = 0;

  final String id;
  final AppNotification notification;
}

class _NotificationBanner extends StatefulWidget {
  const _NotificationBanner({
    super.key,
    required this.notification,
    required this.onDismiss,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onDismiss;
  final VoidCallback onTap;

  @override
  State<_NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<_NotificationBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent = NotificationStyle.accentColor(widget.notification.type);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: FadeTransition(
        opacity: _opacity,
        child: SlideTransition(
          position: _slide,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(14),
            color: colorScheme.surface,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border(
                    left: BorderSide(color: accent, width: 4),
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(NotificationStyle.icon(widget.notification.type),
                        color: accent, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.notification.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.notification.body.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              widget.notification.body,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.72),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (widget.notification.actionLabel != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              widget.notification.actionLabel!,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onDismiss,
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
