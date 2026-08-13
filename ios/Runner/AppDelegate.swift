import UIKit
import AVFoundation
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var privacyView: UIView?

  override func applicationWillResignActive(_ application: UIApplication) {
    let view = UIView(frame: window?.bounds ?? .zero)
    view.backgroundColor = UIColor.systemBackground
    window?.addSubview(view)
    privacyView = view
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    privacyView?.removeFromSuperview()
    privacyView = nil
  }

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
