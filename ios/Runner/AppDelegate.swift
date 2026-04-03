import UIKit
import Flutter
import FirebaseCore
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var processTextChannel: FlutterMethodChannel?
  private var pendingText: String?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Firebase must be configured before GeneratedPluginRegistrant so that
    // firebase_messaging's Flutter plugin finds an already-initialised app.
    FirebaseApp.configure()

    GeneratedPluginRegistrant.register(with: self)

    // Request notification permissions and register for remote notifications.
    UNUserNotificationCenter.current().delegate = self
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(
      options: authOptions,
      completionHandler: { _, _ in }
    )
    application.registerForRemoteNotifications()

    // Hand the APNs token to the firebase_messaging Flutter plugin.
    Messaging.messaging().delegate = self

    if let controller = window?.rootViewController as? FlutterViewController {
      processTextChannel = FlutterMethodChannel(
        name: "scagen/process_text",
        binaryMessenger: controller.binaryMessenger
      )
      processTextChannel?.setMethodCallHandler { [weak self] call, result in
        guard let self = self else { return result(nil) }
        switch call.method {
        case "getInitialText":
          result(self.pendingText)
          self.pendingText = nil
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    if let launchUrl = launchOptions?[.url] as? URL {
      captureProcessText(from: launchUrl)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    let handled = captureProcessText(from: url)
    return handled || super.application(app, open: url, options: options)
  }

  // Forward APNs device token to Firebase so FCM can map it.
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Messaging.messaging().apnsToken = deviceToken
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  @discardableResult
  private func captureProcessText(from url: URL) -> Bool {
    // Enforce strict scheme + host to prevent arbitrary URL injection.
    guard url.scheme?.lowercased() == "scagen",
          url.host?.lowercased() == "process-text",
          let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
          let text = components.queryItems?.first(where: { $0.name == "text" })?.value else {
      return false
    }

    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

    // Reject empty payloads.
    guard !trimmed.isEmpty else { return false }

    // Cap payload to 4 KB to prevent DoS / memory exhaustion via crafted URLs.
    guard trimmed.utf8.count <= 4096 else { return false }

    pendingText = trimmed
    processTextChannel?.invokeMethod("onText", arguments: trimmed)
    return true
  }
}

// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    // The firebase_messaging Flutter plugin handles token forwarding to Dart.
    // Nothing extra needed here.
  }
}
