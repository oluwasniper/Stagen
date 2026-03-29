import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

enum NotificationType { info, success, warning, error }

enum NotificationSource { local, server }

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
    return AppNotification(
      id: doc['\$id']?.toString() ?? const Uuid().v4(),
      title: doc['title']?.toString() ?? '',
      body: doc['body']?.toString() ?? '',
      type: type,
      source: NotificationSource.server,
      createdAt: DateTime.tryParse(doc['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      actionLabel: doc['actionLabel']?.toString(),
      actionRoute: doc['actionRoute']?.toString(),
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
