import Flutter
import UIKit

import FlareLane

public class SwiftFlareLaneFlutterPlugin: NSObject, FlutterPlugin {
  var launchOptions: [UIApplication.LaunchOptionsKey: Any]?
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
    
    FlareLane.setSdkInfo(sdkType: .flutter, sdkVersion: "1.0.1")
  }
  
  // ----- FLUTTER INVOKE HANDLER -----
  
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let method = call.method
    
    if (method == "initialize") {
      let projectId = call.arguments as! String
      self.initialize(projectId: projectId)
      result(true)
    } else if (method == "setLogLevel") {
      let logLevel = call.arguments as! Int
      self.setLogLevel(logLevel: logLevel)
      result(true)
    } else if (method == "setUserId") {
      let userId = call.arguments as? String
      self.setUserId(userId: userId)
      result(true)
    } else if (method == "setTags") {
      let tags = call.arguments as! [String: Any]
      self.setTags(tags: tags)
      result(true)
    } else if (method == "deleteTags") {
      let keys = call.arguments as! [String]
      self.deleteTags(keys: keys)
      result(true)
    } else if (method == "setIsSubscribed") {
      let isSubscribed = call.arguments as! Bool
      self.setIsSubscribed(isSubscribed: isSubscribed)
      result(true)
    } else if (method == "setNotificationConvertedHandler") {
      self.setNotificationConvertedHandler()
      result(true)
    } else {
      result(false)
    }
  }
  
  // ----- PUBLIC METHODS -----
  
  func setLogLevel (logLevel: Int) {
    let level = LogLevel(rawValue: logLevel) ?? LogLevel.verbose
    FlareLane.setLogLevel(level: level)
  }
  
  func initialize (projectId: String) {
    let launchOptions = self.launchOptions
    FlareLane.initWithLaunchOptions(launchOptions, projectId: projectId)
    self.launchOptions = nil
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
  
  func setIsSubscribed(isSubscribed: Bool) {
    FlareLane.setIsSubscribed(isSubscribed: isSubscribed)
  }
  
  // ----- HANDLERS -----
  
  func setNotificationConvertedHandler() {
    FlareLane.setNotificationConvertedHandler() { payload in
      DispatchQueue.main.async {
        SwiftFlareLaneFlutterPlugin.channel?.invokeMethod("setNotificationConvertedHandlerInvokeCallback", arguments: payload.toDictionary())
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
