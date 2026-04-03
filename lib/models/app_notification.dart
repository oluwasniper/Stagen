import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

enum NotificationType { info, success, warning, error }

enum NotificationSource { local, server }

const int _kNotificationTitleMaxLength = 120;
const int _kNotificationBodyMaxLength = 500;
const int _kNotificationActionLabelMaxLength = 64;
const int _kNotificationActionRouteMaxLength = 256;

/// An in-app notification entry.
///
/// Local notifications are created directly by the app (e.g. "QR saved").
/// Server notifications arrive via Appwrite Realtime from the `notifications`
/// collection and represent personalised messages sent by you or automated rules.
@immutable
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.source,
    required this.createdAt,
    this.actionLabel,
    this.actionRoute,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationSource source;
  final DateTime createdAt;

  /// Optional CTA label shown on the banner / inbox item.
  final String? actionLabel;

  /// GoRouter path to push when the action is tapped.
  final String? actionRoute;

  final bool isRead;

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      type: type,
      source: source,
      createdAt: createdAt,
      actionLabel: actionLabel,
      actionRoute: actionRoute,
      isRead: isRead ?? this.isRead,
    );
  }

  /// Deserialise from an Appwrite document map.
  factory AppNotification.fromAppwrite(Map<String, dynamic> doc) {
    final typeStr = doc['type']?.toString() ?? 'info';
    final type = NotificationType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => NotificationType.info,
    );
    final title = _sanitizeNotificationText(
      doc['title'],
      maxLength: _kNotificationTitleMaxLength,
    );
    final body = _sanitizeNotificationText(
      doc['body'],
      maxLength: _kNotificationBodyMaxLength,
    );
    final actionLabel = _sanitizeNotificationText(
      doc['actionLabel'],
      maxLength: _kNotificationActionLabelMaxLength,
    );
    final actionRoute = _sanitizeRoute(doc['actionRoute']);
    return AppNotification(
      id: doc['\$id']?.toString() ?? const Uuid().v4(),
      title: title,
      body: body,
      type: type,
      source: NotificationSource.server,
      createdAt: DateTime.tryParse(doc['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      actionLabel: actionLabel.isEmpty ? null : actionLabel,
      actionRoute: actionRoute,
      isRead: doc['isRead'] == true,
    );
  }

  /// Convenience factory for transient local banners.
  factory AppNotification.local({
    required String title,
    required String body,
    NotificationType type = NotificationType.info,
    String? actionLabel,
    String? actionRoute,
  }) {
    return AppNotification(
      id: const Uuid().v4(),
      title: title,
      body: body,
      type: type,
      source: NotificationSource.local,
      createdAt: DateTime.now(),
      actionLabel: actionLabel,
      actionRoute: actionRoute,
    );
  }
}

String _sanitizeNotificationText(
  Object? raw, {
  required int maxLength,
}) {
  final normalized = raw
      ?.toString()
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  if (normalized == null || normalized.isEmpty) return '';
  if (normalized.length <= maxLength) return normalized;
  return normalized.substring(0, maxLength);
}

String? _sanitizeRoute(Object? raw) {
  final route = _sanitizeNotificationText(
    raw,
    maxLength: _kNotificationActionRouteMaxLength,
  );
  if (route.isEmpty) return null;
  return route;
}
