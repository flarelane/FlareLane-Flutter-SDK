# FlareLane-Flutter-SDK

Welcome to [FlareLane](https://flarelane.com)

## WebView Bridge (hybrid apps)

For hybrid apps that embed pages running the FlareLane Web SDK, the plugin
exposes a bridge so identity (`deviceId` / `userId` / `projectId`) and SDK
calls (`setUserId`, `setTags`, `trackEvent`, `setUserAttributes`,
`syncDeviceData`) stay aligned between native and web.

The bridge name and class name match the native Android/iOS SDKs:
`FlareLaneJavascriptInterface` + `BRIDGE_NAME`. The plugin ships
library-named adapters that expose members 1:1 with each webview library's
slot names — drop them into your existing webview wiring.

Two webview libraries are supported as first-class adapters:

| Webview library | Adapter import |
|---|---|
| `webview_flutter` (official) | `package:flarelane_flutter/adapters/webview_flutter.dart` |
| `flutter_inappwebview` | `package:flarelane_flutter/adapters/flutter_inappwebview.dart` |

The webview libraries are **not** transitive dependencies of this plugin —
add only the one you actually use to your own app's `pubspec.yaml`.

### webview_flutter

```dart
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flarelane_flutter/adapters/webview_flutter.dart';

final controller = WebViewController()
  ..setJavaScriptMode(JavaScriptMode.unrestricted)
  // additive slot — adapter channel sits alongside your own channels.
  ..addJavaScriptChannel('MyChannel', onMessageReceived: myChannelHandler)
  ..addJavaScriptChannel(
    FlareLaneJavascriptInterface.BRIDGE_NAME,
    onMessageReceived:
        FlareLaneJavascriptInterface.onMessageReceived(controller),
  )
  // single-valued slot — call adapter callback inside your own callback.
  ..setNavigationDelegate(NavigationDelegate(
    onPageStarted: (url) async {
      await FlareLaneJavascriptInterface.onPageStarted(controller)(url);
      myExistingOnPageStarted(url);
    },
    onPageFinished: myExistingOnPageFinished,
  ));
```

The adapter exposes:

- `FlareLaneJavascriptInterface.BRIDGE_NAME` — channel name constant.
- `FlareLaneJavascriptInterface.onMessageReceived(controller)` — factory
  that returns a callback for `addJavaScriptChannel(…, onMessageReceived: …)`.
- `FlareLaneJavascriptInterface.onPageStarted(controller)` — factory that
  returns a callback for `NavigationDelegate(onPageStarted: …)`.

### flutter_inappwebview

```dart
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flarelane_flutter/adapters/flutter_inappwebview.dart';

InAppWebView(
  initialUrlRequest: URLRequest(url: WebUri(url)),
  // additive slot — merge adapter UserScripts with your own.
  initialUserScripts: UnmodifiableListView<UserScript>([
    ...FlareLaneJavascriptInterface.initialUserScripts,
    ...myUserScripts,
  ]),
  // single-valued slot — register the adapter handler inside your own callback.
  onWebViewCreated: (controller) {
    controller.addJavaScriptHandler(
      handlerName: FlareLaneJavascriptInterface.BRIDGE_NAME,
      callback: FlareLaneJavascriptInterface.handlerCallback(controller),
    );
    myExistingOnWebViewCreated(controller);
  },
);
```

The adapter exposes:

- `FlareLaneJavascriptInterface.BRIDGE_NAME` — channel name constant.
- `FlareLaneJavascriptInterface.initialUserScripts` — a `UserScript` list
  for `InAppWebView(initialUserScripts: …)`. Injection time is
  `AT_DOCUMENT_START` so the Web SDK detects the bridge before its own
  scripts run.
- `FlareLaneJavascriptInterface.handlerCallback(controller)` — factory
  that returns a callback for `controller.addJavaScriptHandler(…, callback: …)`.

### Class name collision (rare)

Both adapter files declare `class FlareLaneJavascriptInterface`. In typical
apps you import only one of them, so there is no collision. If you must
import both in the same Dart file, use `import as` prefixes:

```dart
import 'package:flarelane_flutter/adapters/webview_flutter.dart' as fl_wvf;
import 'package:flarelane_flutter/adapters/flutter_inappwebview.dart' as fl_iaw;

fl_wvf.FlareLaneJavascriptInterface.BRIDGE_NAME
fl_iaw.FlareLaneJavascriptInterface.BRIDGE_NAME
```

### Other webview packages

This plugin only ships first-class adapters for `webview_flutter` and
`flutter_inappwebview`. If you use a different webview library, port one
of the adapter implementations in `lib/adapters/` to your library's slot
names — the shared message routing and injection script logic lives in
`lib/src/bridge_core.dart` (internal) and is the source of truth.

### Notes

- The injected JS is idempotent — safe to inject twice.
- Inject *before* the Web SDK loads. With `webview_flutter`, the adapter
  uses `onPageStarted` which is usually fast enough; for stricter timing,
  `flutter_inappwebview`'s `AT_DOCUMENT_START` UserScript injection (built
  into that adapter) is preferred.
- `setUserAttributes` is available on Android, iOS, Flutter, and React
  Native SDKs with consistent semantics.
