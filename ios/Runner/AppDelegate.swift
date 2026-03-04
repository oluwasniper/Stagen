import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var processTextChannel: FlutterMethodChannel?
  private var pendingText: String?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

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
    captureProcessText(from: url)
    return super.application(app, open: url, options: options)
  }

  private func captureProcessText(from url: URL) {
    guard url.scheme?.lowercased() == "scagen",
          url.host?.lowercased() == "process-text",
          let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
          let text = components.queryItems?.first(where: { $0.name == "text" })?.value,
          !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      return
    }

    pendingText = text
    processTextChannel?.invokeMethod("onText", arguments: text)
  }
}
