//
//  NotificationService.swift
//  FlareLaneNotificationServiceExtension
//
//  Created by MinHyeok Kim on 2022/04/12.
//

import UserNotifications
import FlareLane

class NotificationService: UNNotificationServiceExtension {
  
  var contentHandler: ((UNNotificationContent) -> Void)?
  var receivedRequest: UNNotificationRequest!
  var bestAttemptContent: UNMutableNotificationContent?
  
  override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
    if FlareLaneNotificationServiceExtensionHelper.shared.isFlareLaneNotification(request) {
      FlareLaneNotificationServiceExtensionHelper.shared.didReceive(request, withContentHandler: contentHandler)
    } else {
    }
  }
  
  override func serviceExtensionTimeWillExpire() {
    FlareLaneNotificationServiceExtensionHelper.shared.serviceExtensionTimeWillExpire()
  }
}
