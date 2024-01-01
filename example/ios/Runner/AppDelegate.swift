import UIKit
import Flutter
import FlareLane

@UIApplicationMain
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
    FlareLaneNotificationCenter.shared.userNotificationCenter(center, willPresent: notification, withCompletionHandler: completionHandler)
  }
  
  override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    FlareLaneNotificationCenter.shared.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
  }
}
