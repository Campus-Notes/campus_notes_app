import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  var blurEffectView: UIVisualEffectView?
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // MARK: - Screenshot Protection
  // Blur screen when app goes to background to prevent screenshot content leak
  override func applicationWillResignActive(_ application: UIApplication) {
    // Create blur effect
    let blurEffect = UIBlurEffect(style: .light)
    let blurView = UIVisualEffectView(effect: blurEffect)
    blurView.frame = window?.frame ?? CGRect.zero
    blurView.tag = 999 // Tag to identify and remove later
    
    // Add app name overlay
    let label = UILabel()
    label.text = "Campus Notes+"
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
    label.textColor = UIColor(red: 0.39, green: 0.40, blue: 0.95, alpha: 1.0) // Primary color
    label.frame = blurView.bounds
    blurView.contentView.addSubview(label)
    
    window?.addSubview(blurView)
    self.blurEffectView = blurView
  }
  
  // Remove blur when app becomes active
  override func applicationDidBecomeActive(_ application: UIApplication) {
    blurEffectView?.removeFromSuperview()
    blurEffectView = nil
  }
}
