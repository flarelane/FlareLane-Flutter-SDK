import UIKit
import Flutter
import FlareLane

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    UNUserNotificationCenter.current().delegate = self
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    FlareLaneAppDelegate.shared.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }
  
  
  override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    // 2
    FlareLaneNotificationCenter.shared.userNotificationCenter(center, willPresent: notification, withCompletionHandler: completionHandler)
  }
  
  override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    // 3
    FlareLaneNotificationCenter.shared.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
  }
}
