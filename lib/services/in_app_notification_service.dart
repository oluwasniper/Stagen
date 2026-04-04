import 'dart:async';
import 'dart:developer' as dev;

import '../models/app_notification.dart';

/// Singleton bus for in-app notifications.
///
/// Two responsibilities:
///   1. Expose a [bannerStream] that [NotificationOverlay] listens to in order
///      to show auto-dismissing banners while the app is foregrounded.
///   2. Expose [post] so any service or widget can publish a notification
///      without needing a BuildContext or Riverpod ref.
///
/// The [notificationProvider] (Riverpod) listens to [allStream] to build the
/// persistent inbox list.
class InAppNotificationService {
  InAppNotificationService._();

  static final InAppNotificationService instance = InAppNotificationService._();

  // Banner stream — used by NotificationOverlay for transient toasts.
  final StreamController<AppNotification> _bannerController =
      StreamController<AppNotification>.broadcast();

  // All-notifications stream — used by notificationProvider for inbox.
  final StreamController<AppNotification> _allController =
      StreamController<AppNotification>.broadcast();

  Stream<AppNotification> get bannerStream => _bannerController.stream;
  Stream<AppNotification> get allStream => _allController.stream;

  /// Post a notification. Pushes to both streams.
  ///
  /// [showBanner] controls whether the overlay should show a toast for this
  /// notification (e.g. you may want to add a server notification to the inbox
  /// silently without a banner if the user is already on the notifications screen).
  void post(AppNotification notification, {bool showBanner = true}) {
    try {
      _allController.add(notification);
      if (showBanner) {
        _bannerController.add(notification);
      }
    } catch (e, st) {
      dev.log(
        '[InAppNotificationService] post failed: $e',
        stackTrace: st,
        name: 'InAppNotificationService',
      );
    }
  }

  /// Convenience: post a local info/success/warning/error notification.
  void postLocal({
    required String title,
    required String body,
    NotificationType type = NotificationType.info,
    String? actionLabel,
    String? actionRoute,
    bool showBanner = true,
  }) {
    post(
      AppNotification.local(
        title: title,
        body: body,
        type: type,
        actionLabel: actionLabel,
        actionRoute: actionRoute,
      ),
      showBanner: showBanner,
    );
  }

  void dispose() {
    _bannerController.close();
    _allController.close();
  }
}
