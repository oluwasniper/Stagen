import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_notification.dart';
import '../services/in_app_notification_service.dart';

/// Holds the full notification inbox list (newest first).
///
/// Listens to [InAppNotificationService.allStream] so any call to
/// [InAppNotificationService.post] is automatically reflected here.
class NotificationNotifier extends StateNotifier<List<AppNotification>> {
  NotificationNotifier() : super(const []) {
    _sub = InAppNotificationService.instance.allStream.listen(_onNotification);
  }

  late final StreamSubscription<AppNotification> _sub;

  void _onNotification(AppNotification notification) {
    // Newest first; cap at 100 to avoid unbounded growth.
    final updated = [notification, ...state];
    state = updated.length > 100 ? updated.sublist(0, 100) : updated;
  }

  /// Mark a single notification as read by id.
  void markRead(String id) {
    state = [
      for (final n in state) n.id == id ? n.copyWith(isRead: true) : n,
    ];
  }

  /// Mark all notifications as read.
  void markAllRead() {
    state = [for (final n in state) n.copyWith(isRead: true)];
  }

  /// Remove a notification from the inbox.
  void dismiss(String id) {
    state = state.where((n) => n.id != id).toList();
  }

  /// Clear the entire inbox.
  void clearAll() {
    state = const [];
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, List<AppNotification>>((ref) {
  return NotificationNotifier();
});

/// Derived provider: count of unread notifications (for badge).
final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(notificationProvider).where((n) => !n.isRead).length;
});
