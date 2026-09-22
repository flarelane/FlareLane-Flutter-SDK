## 1.11.3

- Bump native FlareLane Android/iOS SDKs to 1.11.3: a notification tap now resumes the app's existing task as-is instead of relaunching the main activity (Android), and idempotent POST retries carry an `Idempotency-Key` header.
- Minimum supported iOS version raised to 15.0 (required by Xcode 27).

## 1.11.2

- Bump native FlareLane Android/iOS SDKs to 1.11.2: transient network failures retry automatically with jittered backoff, `trackEvent` payloads carry a client-generated `insertId` so the backend can deduplicate resends, a 410 from a device endpoint stops the SDK for the rest of the process, and the pending task queue is bounded at 100 tasks.
- Add notification grouping (threadId) and chat-style communication notifications; `threadId` and `communication` are exposed on the notification payload model.
- Route Dart-side logs through a level-gated Logger, so `LogLevel.none` silences Flutter-layer logs too (they previously ignored the log level).

## 1.10.3

- Bump native iOS dependency to FlareLane iOS SDK 1.10.3 (fixes action buttons not displaying in some environments such as iOS 16).
- Align plugin version with the latest native SDK version (1.10.3).

## 1.10.2

- Bump native dependencies to FlareLane Android SDK 1.10.1 / iOS SDK 1.10.2 (in-app message callback reliability fixes).
- Align plugin version with the latest native SDK version (1.10.2); 1.10.1 was skipped.

## 1.10.0

- Add `setUserAttributes` public method.
- Add notification action button surface: `buttons`, `clickedButtonIndex`, `clickedButton`, `clickedUrl`.
- Add `FlareLaneJavascriptInterface` adapter for `webview_flutter` and `flutter_inappwebview` hybrid apps (see README).
- Bump native dependencies to FlareLane Android/iOS SDK 1.10.0.

## 1.9.2

- Upgrade Android SDK (1.8.4)
- Upgrade iOS SDK (1.9.2)

## 1.8.1

- Upgrade Android SDK (1.8.2)
- Upgrade iOS SDK (1.7.3)

## 1.8.0

- Support AGP 8

## 1.7.1

- Upgrade Android & iOS SDK (1.7.1)
  - Enhance sustainability: Managing functions and tasks sequentially

## 1.7.0

- Upgrade Android & iOS SDK (1.7.0)
  - Support In-App Message.
  - Ensure the function invokes after init.

## 1.6.2

- Remove `getTags` because of security issues.
- Remove `deleteTags`.
- Change `setTags` to enable null value.
- Upgrade Android SDK ([1.6.1](https://github.com/flarelane/FlareLane-Android-SDK/releases)).

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
