import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private static let screenCaptureChannel =
    "fortuneboot/screen_capture_protection"
  private static let setScreenCaptureAllowedMethod =
    "setScreenCaptureAllowed"

  private var privacyView: UIView?
  private var screenCaptureProtectionEnabled = true

  override func applicationWillResignActive(_ application: UIApplication) {
    updatePrivacyView()
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    updatePrivacyView()
  }

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    configureScreenCaptureChannel()
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(screenCaptureStatusDidChange),
      name: UIScreen.capturedDidChangeNotification,
      object: nil
    )
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  private func configureScreenCaptureChannel() {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return
    }

    let channel = FlutterMethodChannel(
      name: Self.screenCaptureChannel,
      binaryMessenger: controller.binaryMessenger
    )
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == Self.setScreenCaptureAllowedMethod else {
        result(FlutterError(
          code: "not_implemented",
          message: "Unsupported screen capture method",
          details: nil
        ))
        return
      }
      guard let arguments = call.arguments as? [String: Any],
            let allowed = arguments["allowed"] as? Bool else {
        result(FlutterError(
          code: "invalid_argument",
          message: "Missing allowed value",
          details: nil
        ))
        return
      }

      self?.screenCaptureProtectionEnabled = !allowed
      self?.updatePrivacyView()
      result(nil)
    }
  }

  @objc private func screenCaptureStatusDidChange() {
    updatePrivacyView()
  }

  private func updatePrivacyView() {
    let shouldProtect = screenCaptureProtectionEnabled &&
      (UIApplication.shared.applicationState != .active || UIScreen.main.isCaptured)
    if shouldProtect {
      showPrivacyView()
    } else {
      hidePrivacyView()
    }
  }

  private func showPrivacyView() {
    guard privacyView == nil, let window else { return }

    let view = UIView(frame: window.bounds)
    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.backgroundColor = .systemBackground
    window.addSubview(view)
    privacyView = view
  }

  private func hidePrivacyView() {
    privacyView?.removeFromSuperview()
    privacyView = nil
  }
}
