import 'package:webview_flutter/webview_flutter.dart';

import '../src/bridge_core.dart';

/// `webview_flutter`-specific adapter that exposes the FlareLane bridge in
/// shape that matches `webview_flutter`'s controller slot names. The bridge
/// protocol (`BridgeCore.javaScriptInjection` + `handle`) is
/// reused as-is from the low-level core.
///
/// Compatible with `webview_flutter: '>=4.0.0 <5.0.0'`. Only `WebViewController`,
/// `JavaScriptMessage`, and `runJavaScript(String)` are touched — these have
/// been stable across the entire 4.x series.
///
/// Customers wire their `WebViewController` as usual — the adapter members
/// (`onMessageReceived(controller)`, `onPageStarted(controller)`) drop into
/// the matching slot 1:1 by name.
///
/// Example — alongside the customer's existing channels / navigation callbacks:
///
/// ```dart
/// final controller = WebViewController()
///   ..setJavaScriptMode(JavaScriptMode.unrestricted)
///   ..addJavaScriptChannel('MyChannel', onMessageReceived: myHandler)
///   ..addJavaScriptChannel(
///     FlareLaneJavascriptInterface.BRIDGE_NAME,
///     onMessageReceived:
///         FlareLaneJavascriptInterface.onMessageReceived(controller),
///   )
///   ..setNavigationDelegate(NavigationDelegate(
///     onPageStarted: (url) async {
///       await FlareLaneJavascriptInterface.onPageStarted(controller)(url);
///       myOnPageStarted(url);
///     },
///   ));
/// ```
class FlareLaneJavascriptInterface {
  /// Channel name constant — mirrors the native SDK's `BRIDGE_NAME`.
  // ignore: constant_identifier_names
  static const String BRIDGE_NAME = 'FlareLaneNativeBridge';

  /// Returns a callback ready to plug into
  /// `controller.addJavaScriptChannel(BRIDGE_NAME, onMessageReceived: …)`.
  /// Each incoming message is routed through the FlareLane bridge core; if
  /// the core returns a JS string (e.g. the `syncDeviceData` response), it
  /// is evaluated back into the webview via the controller.
  static Future<void> Function(JavaScriptMessage) onMessageReceived(
      WebViewController controller) {
    return (JavaScriptMessage message) async {
      final String? js = await BridgeCore.handle(message.message);
      if (js != null) {
        await controller.runJavaScript(js);
      }
    };
  }

  /// Returns a callback ready to plug into
  /// `NavigationDelegate(onPageStarted: …)`. Injects the bridge shim near
  /// the start of page load. `webview_flutter` does not expose a true
  /// document-start hook, so an inline `<head>` script that reads
  /// `window.FlareLaneBridge` synchronously may still run before the shim
  /// on some platforms. For strict document-start timing, prefer the
  /// `flutter_inappwebview` adapter (which uses `AT_DOCUMENT_START`
  /// UserScript injection).
  static Future<void> Function(String) onPageStarted(
      WebViewController controller) {
    return (String url) async {
      await controller
          .runJavaScript(BridgeCore.javaScriptInjection);
    };
  }
}
