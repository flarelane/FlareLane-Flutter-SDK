## 1.6.1

- iOS: Add privacy manifest

## 1.6.0

- **[Action Required]** Support processing the URL automatically
  - If you have a custom clicked handler, set `flarelane_dismiss_launch_url` as `true`
- Support a javascript bridge for webview

## 1.5.1

- Fix not inovking handler issue if first subscription

## 1.5.0

- Remove `setIsSubscribed()`-> use `subscribe()` or `unsubscribe()`
- Name Changed: `setNotificationConvertedHandler()` -> `setNotificationClickedHandler()`
- Support `setNotificationForegroundReceivedHandler()`

### Android

- Can change accentColor: `flarelane_notification_accent_color` at `values/strings.xml`
- Can change default channel name: `flarelane_default_channel_name` at `values/strings.xml`

## 1.4.0

- Enable Dynamic Subscribing

## 1.3.1

- Add getTags method

## 1.3.0

- Add trackEvent method

## 1.2.0

- Support Android 13

## 1.1.0

- Finaaaally, You can use FlareLane with other notification services!
  - Disable swizzling option (Set FlareLaneSwizzlingEnabled to false in Info.plist)
  - Need to add some delegate methods
- New Method: getDeviceId()
- Update Native Android SDK (1.1.0)
- Update Native Android SDK (1.1.0)
- Some bug fixes
  - Multiple creating device

## 1.0.5

- Add a data field to notification class
- Update Native Android SDK (1.0.14)
- Update Native Android SDK (1.0.7)

## 1.0.4

- Update Native iOS SDK (1.0.6)

## 1.0.3

- Update Native Android SDK (1.0.13)

## 1.0.2

SDK Version Update

## 1.0.1

SDK Version Update

## 1.0.0

FlareLane Flutter SDK just has been created.
