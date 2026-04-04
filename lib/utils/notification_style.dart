import 'package:flutter/material.dart';

import '../models/app_notification.dart';

class NotificationStyle {
  const NotificationStyle._({
    required this.color,
    required this.iconData,
  });

  final Color color;
  final IconData iconData;

  static const NotificationStyle _success = NotificationStyle._(
    color: Color(0xff22C55E),
    iconData: Icons.check_circle_outline,
  );

  static const NotificationStyle _warning = NotificationStyle._(
    color: Color(0xffF59E0B),
    iconData: Icons.warning_amber_outlined,
  );

  static const NotificationStyle _error = NotificationStyle._(
    color: Color(0xffEF4444),
    iconData: Icons.error_outline,
  );

  static const NotificationStyle _info = NotificationStyle._(
    color: Color(0xff3B82F6),
    iconData: Icons.info_outline,
  );

  static NotificationStyle resolve(NotificationType type) => switch (type) {
        NotificationType.success => _success,
        NotificationType.warning => _warning,
        NotificationType.error => _error,
        NotificationType.info => _info,
      };

  static Color accentColor(NotificationType type) => resolve(type).color;

  static IconData icon(NotificationType type) => resolve(type).iconData;
}
