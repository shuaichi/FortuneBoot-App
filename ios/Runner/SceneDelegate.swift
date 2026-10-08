import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  private static let screenCaptureChannel =
    "fortuneboot/screen_capture_protection"
  private static let setScreenCaptureAllowedMethod =
    "setScreenCaptureAllowed"

  private var privacyView: UIView?
  private var screenCaptureProtectionEnabled = true
  private var screenCaptureProtectionConfigured = false

  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    configureScreenCaptureProtection()
  }

  override func sceneDidBecomeActive(_ scene: UIScene) {
    super.sceneDidBecomeActive(scene)
    updatePrivacyView()
  }

  override func sceneWillResignActive(_ scene: UIScene) {
    super.sceneWillResignActive(scene)
    updatePrivacyView()
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  private func configureScreenCaptureProtection() {
    guard !screenCaptureProtectionConfigured,
          let controller = window?.rootViewController as? FlutterViewController
    else {
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

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(screenCaptureStatusDidChange),
      name: UIScreen.capturedDidChangeNotification,
      object: nil
    )
    screenCaptureProtectionConfigured = true
  }

  @objc private func screenCaptureStatusDidChange() {
    updatePrivacyView()
  }

  private func updatePrivacyView() {
    let windowScene = window?.windowScene
    let isSceneActive = windowScene?.activationState == .foregroundActive
    let isScreenCaptured = windowScene?.screen.isCaptured ?? false
    let shouldProtect = screenCaptureProtectionEnabled &&
      (windowScene == nil || !isSceneActive || isScreenCaptured)
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
