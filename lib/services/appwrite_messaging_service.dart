// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:developer' as dev;

import 'package:appwrite/appwrite.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

import '../config/app_config.dart';
import '../models/app_notification.dart';
import 'in_app_notification_service.dart';
import 'telemetry_service.dart';

// ─── Appwrite Messaging + Realtime service ────────────────────────────────────
//
// SETUP CHECKLIST (do this once before using push notifications):
//
// 1. FCM (Android push):
//    a. Create a Firebase project at console.firebase.google.com
//    b. Add your Android app (package: com.scagen.app) → download google-services.json
//       → place it at android/app/google-services.json
//    c. Add to android/build.gradle:
//         classpath 'com.google.gms:google-services:4.4.0'
//    d. Add to android/app/build.gradle:
//         apply plugin: 'com.google.gms.google-services'
//         implementation 'com.google.firebase:firebase-messaging'
//    e. In Appwrite Console → Messaging → Providers → Add FCM provider
//       → paste your FCM Server Key (from Firebase project settings → Cloud Messaging)
//       → note the provider ID → set APPWRITE_MESSAGING_PROVIDER_ID in .env
//
// 2. APNs (iOS push):
//    a. Apple Developer → Certificates → Keys → create APNs key → download .p8
//    b. In Appwrite Console → Messaging → Providers → Add APNs provider
//       → upload the .p8 file, set Key ID, Team ID, Bundle ID
//    c. In Xcode: Signing & Capabilities → + Capability → Push Notifications
//
// 3. Appwrite `notifications` collection (for in-app personalised messages):
//    Database: scagen_db
//    Collection: notifications
//    Attributes:
//      - title       (string, 255, required)
//      - body        (string, 1024, required)
//      - type        (string, 50, default: "info")  — info|success|warning|error
//      - userId      (string, 255, required)         — target user's Appwrite $id
//      - actionLabel (string, 255, optional)
//      - actionRoute (string, 255, optional)
//      - isRead      (boolean, default: false)
//      - createdAt   (string, 50, required)
//    Permissions: users can read their own documents
//      → add role: user:<userId> with read permission
//      → or use a server-side Function to create documents with user read permission
//
// 4. Pass the dart-define at build time:
//    APPWRITE_MESSAGING_PROVIDER_ID=<your_fcm_or_apns_provider_id>

/// Database / collection identifiers for in-app notifications.
abstract final class _NotificationCollection {
  static const String databaseId = 'scagen_db';
  static const String collectionId = 'notifications';
}

class AppwriteMessagingService {
  AppwriteMessagingService({
    required Client client,
    required TelemetryService Function() telemetryReader,
  })  : _account = Account(client),
        _databases = Databases(client),
        _realtime = Realtime(client),
        _telemetryReader = telemetryReader;

  final Account _account;
  final Databases _databases;
  final Realtime _realtime;
  final TelemetryService Function() _telemetryReader;

  RealtimeSubscription? _realtimeSubscription;
  StreamSubscription<String>? _tokenRefreshSub;
  String? _currentUserId;

  // ── Push token registration ──────────────────────────────────────────────

  /// Register a device push token with Appwrite Messaging.
  ///
  /// Call this after the user signs in (or on anonymous session start) once
  /// you have obtained a token from firebase_messaging:
  ///
  /// ```dart
  /// final token = await FirebaseMessaging.instance.getToken();
  /// if (token != null) {
  ///   await messagingService.registerPushToken(
  ///     userId: user.$id,
  ///     token: token,
  ///     targetId: 'device_${user.$id}', // unique per device/user combo
  ///   );
  /// }
  /// ```
  ///
  /// [targetId] must be unique per device. Using `device_<userId>` works for
  /// single-device users; for multi-device support use a per-installation ID.
  /// Request permission and register the FCM token with Appwrite Messaging.
  ///
  /// Call once after the user is authenticated. Safe to call on every sign-in —
  /// Appwrite ignores duplicate [targetId] registrations.
  Future<void> initFcm(String userId) async {
    try {
      // Request permission (iOS prompts user; Android 13+ also prompts).
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      _telemetryReader().track(
        TelemetryEvents.pushRegistrationAttempted,
        properties: {'status': settings.authorizationStatus.name},
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        dev.log(
          '[AppwriteMessagingService] push permission denied',
          name: 'AppwriteMessagingService',
        );
        return;
      }

      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) {
        dev.log(
          '[AppwriteMessagingService] FCM token is null — '
          'ensure google-services.json / GoogleService-Info.plist are present',
          name: 'AppwriteMessagingService',
        );
        return;
      }

      await _registerPushToken(
        userId: userId,
        token: token,
        targetId: 'device_$userId',
      );

      // Refresh token when FCM rotates it. Cancel any previous listener first.
      _tokenRefreshSub?.cancel();
      _tokenRefreshSub = FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        _registerPushToken(
          userId: userId,
          token: newToken,
          targetId: 'device_$userId',
        );
      });
    } catch (e, st) {
      dev.log(
        '[AppwriteMessagingService] initFcm failed: $e',
        stackTrace: st,
        name: 'AppwriteMessagingService',
      );
      _telemetryReader().track(
        TelemetryEvents.pushRegistrationFailed,
        properties: {'code': e.runtimeType.toString()},
      );
    }
  }

  Future<void> _registerPushToken({
    required String userId,
    required String token,
    required String targetId,
  }) async {
    if (AppConfig.messagingProviderId.isEmpty) {
      dev.log(
        '[AppwriteMessagingService] APPWRITE_MESSAGING_PROVIDER_ID is not set — '
        'skipping push target registration',
        name: 'AppwriteMessagingService',
      );
      return;
    }
    try {
      await _account.createPushTarget(
        targetId: targetId,
        identifier: token,
        providerId: AppConfig.messagingProviderId,
      );
      _telemetryReader().track(
        TelemetryEvents.pushRegistrationAttempted,
        properties: {'granted': true},
      );
      dev.log(
        '[AppwriteMessagingService] push target registered: $targetId',
        name: 'AppwriteMessagingService',
      );
    } on AppwriteException catch (e, st) {
      // 409 = target already exists — not an error, just update it.
      if (e.code == 409) {
        try {
          await _account.updatePushTarget(
            targetId: targetId,
            identifier: token,
          );
          dev.log(
            '[AppwriteMessagingService] push target updated: $targetId',
            name: 'AppwriteMessagingService',
          );
          return;
        } catch (_) {}
      }
      dev.log(
        '[AppwriteMessagingService] _registerPushToken failed: ${e.message}',
        stackTrace: st,
        name: 'AppwriteMessagingService',
      );
      _telemetryReader().track(
        TelemetryEvents.pushRegistrationFailed,
        properties: {'code': e.code?.toString() ?? 'unknown'},
      );
    }
  }

  // ── Realtime in-app notifications ────────────────────────────────────────

  /// Subscribe to personalised in-app notifications for [userId].
  ///
  /// Listens to Appwrite Realtime on the `notifications` collection scoped to
  /// documents whose `userId` matches the signed-in user. When a new document
  /// arrives (created by you from the Appwrite console or a server Function),
  /// it is posted to [InAppNotificationService] — showing a banner and adding
  /// it to the inbox automatically.
  void subscribeToUserNotifications(String userId) {
    if (_currentUserId == userId) return;
    unsubscribe();
    _currentUserId = userId;

    try {
      _realtimeSubscription = _realtime.subscribe([
        'databases.${_NotificationCollection.databaseId}'
            '.collections.${_NotificationCollection.collectionId}'
            '.documents',
      ]);

      _realtimeSubscription!.stream.listen(
        (event) {
          // Only process create events for this user's documents.
          final isCreate = event.events.any(
            (e) => e.contains('.create'),
          );
          if (!isCreate) return;

          final payload = event.payload;
          if (payload['userId']?.toString() != userId) return;

          try {
            final notification = AppNotification.fromAppwrite(
              Map<String, dynamic>.from(payload),
            );
            InAppNotificationService.instance.post(notification);
            _telemetryReader().track(
              TelemetryEvents.pushNotificationReceived,
              properties: {
                'source': 'realtime',
                'type': notification.type.name,
              },
            );
          } catch (e, st) {
            dev.log(
              '[AppwriteMessagingService] failed to parse realtime notification: $e',
              stackTrace: st,
              name: 'AppwriteMessagingService',
            );
          }
        },
        onError: (Object e, StackTrace st) {
          dev.log(
            '[AppwriteMessagingService] realtime stream error: $e',
            stackTrace: st,
            name: 'AppwriteMessagingService',
          );
        },
      );

      dev.log(
        '[AppwriteMessagingService] subscribed to notifications for user $userId',
        name: 'AppwriteMessagingService',
      );
    } catch (e, st) {
      dev.log(
        '[AppwriteMessagingService] subscribe failed: $e',
        stackTrace: st,
        name: 'AppwriteMessagingService',
      );
    }
  }

  /// Cancel the Realtime subscription and FCM token refresh listener (call on sign-out).
  void unsubscribe() {
    _realtimeSubscription?.close();
    _realtimeSubscription = null;
    _tokenRefreshSub?.cancel();
    _tokenRefreshSub = null;
    _currentUserId = null;
  }

  // ── Fetch historical notifications ───────────────────────────────────────

  /// Load existing unread notifications from Appwrite on sign-in.
  ///
  /// Useful for showing notifications the user missed while offline or before
  /// subscribing to Realtime. Posts each to [InAppNotificationService] inbox
  /// without showing banners (silent load).
  Future<void> loadExistingNotifications(String userId) async {
    try {
      final result = await _databases.listDocuments(
        databaseId: _NotificationCollection.databaseId,
        collectionId: _NotificationCollection.collectionId,
        queries: [
          Query.equal('userId', userId),
          Query.equal('isRead', false),
          Query.orderDesc('\$createdAt'),
          Query.limit(50),
        ],
      );

      for (final doc in result.documents) {
        final notification = AppNotification.fromAppwrite(
          <String, dynamic>{...doc.data, '\$id': doc.$id},
        );
        // Silent: add to inbox only, no banner toast.
        InAppNotificationService.instance.post(notification, showBanner: false);
      }

      dev.log(
        '[AppwriteMessagingService] loaded ${result.documents.length} existing notifications',
        name: 'AppwriteMessagingService',
      );
    } on AppwriteException catch (e, st) {
      // Collection may not exist yet — log and continue.
      dev.log(
        '[AppwriteMessagingService] loadExistingNotifications failed: ${e.message}',
        stackTrace: st,
        name: 'AppwriteMessagingService',
      );
    }
  }
}
