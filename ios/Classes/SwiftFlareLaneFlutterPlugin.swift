import Flutter
import UIKit

import FlareLane

public class SwiftFlareLaneFlutterPlugin: NSObject, FlutterPlugin {
  var launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  var notificationEventCache = [String: FlareLaneNotificationReceivedEvent]()
  static var channel: FlutterMethodChannel?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "com.flarelane.flutter/methods", binaryMessenger: registrar.messenger())
    // To use channel in pulic methods
    SwiftFlareLaneFlutterPlugin.channel = channel

    let instance = SwiftFlareLaneFlutterPlugin()
    // Register flutter invoke
    registrar.addMethodCallDelegate(instance, channel: channel)
    // Register appDelegate
    registrar.addApplicationDelegate(instance)

    FlareLane.setSdkInfo(sdkType: .flutter, sdkVersion: "1.6.2")
  }

  // ----- FLUTTER INVOKE HANDLER -----

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let method = call.method

    if (method == "initialize") {
      let arguments = call.arguments as! [String: Any?]
      let projectId = arguments["projectId"] as! String
      let requestPermissionOnLaunch = arguments["requestPermissionOnLaunch"] as? Bool ?? true
      self.initialize(projectId: projectId, requestPermissionOnLaunch: requestPermissionOnLaunch)
      result(true)
    } else if (method == "setLogLevel") {
      let logLevel = call.arguments as! Int
      self.setLogLevel(logLevel: logLevel)
      result(true)
    } else if (method == "setUserId") {
      let userId = call.arguments as? String
      self.setUserId(userId: userId)
      result(true)
    } else if (method == "getTags") {
      self.getTags() { tags in
        result(tags)
      }
    } else if (method == "setTags") {
      let tags = call.arguments as! [String: Any]
      self.setTags(tags: tags)
      result(true)
    } else if (method == "deleteTags") {
      let keys = call.arguments as! [String]
      self.deleteTags(keys: keys)
      result(true)
    } else if (method == "subscribe") {
      let fallbackToSettings = call.arguments as! Bool
      self.subscribe(fallbackToSettings: fallbackToSettings) { isSubscribed in
        result(isSubscribed)
      }
    } else if (method == "unsubscribe") {
      self.unsubscribe() { isSubscribed in
        result(isSubscribed)
      }
    } else if (method == "isSubscribed") {
      self.isSubscribed() { isSubscribed in
        result(isSubscribed)
      }
    }
    else if (method == "setNotificationClickedHandler") {
      self.setNotificationClickedHandler()
      result(true)
    } else if (method == "setNotificationForegroundReceivedHandler") {
      self.setNotificationForegroundReceivedHandler()
      result(true)
    } else if (method == "displayNotification") {
      if let arguments = call.arguments as? [String: Any?],
         let notificationId = arguments["notificationId"] as? String,
         let event = notificationEventCache[notificationId] {

        event.display()
      }
      result(true)
    } else if (method == "trackEvent") {
      if let arguments = call.arguments as? [String: Any?],
         let type = arguments["type"] as? String {

        let data = arguments["data"] as? [String: Any]
        self.trackEvent(type:type, data: data)
      }

      result(true)
    } else if (method == "getDeviceId") {
      result(self.getDeviceId())
    }
    else {
      result(false)
    }
  }

  // ----- PUBLIC METHODS -----

  func setLogLevel (logLevel: Int) {
    let level = LogLevel(rawValue: logLevel) ?? LogLevel.verbose
    FlareLane.setLogLevel(level: level)
  }

  func initialize (projectId: String, requestPermissionOnLaunch: Bool = true) {
    let launchOptions = self.launchOptions
    FlareLane.initWithLaunchOptions(launchOptions, projectId: projectId, requestPermissionOnLaunch: requestPermissionOnLaunch)
    self.launchOptions = nil
  }

  func subscribe (fallbackToSettings: Bool, callback: @escaping (Bool) -> Void) {
    FlareLane.subscribe(fallbackToSettings: fallbackToSettings) { isSubscribed in
      callback(isSubscribed)
    }
  }

  func unsubscribe (callback: @escaping (Bool) -> Void) {
    FlareLane.unsubscribe() { isSubscribed in
      callback(isSubscribed)
    }
  }

  // ----- SET DEVICE META DATA -----

  func setUserId(userId: String?) {
    FlareLane.setUserId(userId: userId)
  }

  func setTags(tags: [String: Any]) {
    FlareLane.setTags(tags: tags)
  }

  func deleteTags(keys: [String]) {
    FlareLane.deleteTags(keys: keys)
  }

  func trackEvent(type: String, data: [String: Any]?) {
    FlareLane.trackEvent(type, data: data)
  }

  // ----- GET DEVICE META DATA -----

  func isSubscribed(callback: @escaping (Bool) -> Void) {
    FlareLane.isSubscribed() { isSubscribed in
      callback(isSubscribed)
    }
  }

  func getDeviceId() -> String? {
    return FlareLane.getDeviceId()
  }

  func getTags(callback: @escaping ([String: Any]?) -> Void) {
    FlareLane.getTags() { tags in
      callback(tags)
    }
  }

  // ----- HANDLERS -----

  func setNotificationClickedHandler() {
    FlareLane.setNotificationClickedHandler() { notification in
      DispatchQueue.main.async {
        SwiftFlareLaneFlutterPlugin.channel?.invokeMethod("setNotificationClickedHandlerInvokeCallback", arguments: notification.toDictionary())
      }
    }
  }

  func setNotificationForegroundReceivedHandler() {
    FlareLane.setNotificationForegroundReceivedHandler() { event in
      self.notificationEventCache[event.notification.id] = event

      DispatchQueue.main.async {
        SwiftFlareLaneFlutterPlugin.channel?.invokeMethod("setNotificationForegroundReceivedHandlerInvokeCallback", arguments: event.notification.toDictionary())
      }
    }
  }

  // When App is killed, "didReceiveRemoteNotification" has priority before "NotificationCenter" is registered.
  // When the app is initialized and the native module is called(before "NotificationCenter" is registered),
  // it has the same effect as getting the remoteNotification of launchOptions.
  public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) -> Bool {
    let launchOptions = [UIApplication.LaunchOptionsKey.remoteNotification: userInfo] as [UIApplication.LaunchOptionsKey: Any]
    self.launchOptions = launchOptions
    return true
  }
}
