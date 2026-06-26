import 'dart:collection';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../src/bridge_core.dart';

// flutter_inappwebview routes JS-to-native through `callHandler`. The bridge
// shim built into `BridgeCore.javaScriptInjection` targets a
// generic channel named `window.FlareLaneNativeBridge`, so a tiny adapter
// translates that funnel into flutter_inappwebview's actual API call.
const String _channelAdapter = '''
  window.FlareLaneNativeBridge = {
    postMessage: function (s) {
      window.flutter_inappwebview.callHandler('FlareLaneNativeBridge', s);
    }
  };
''';

/// `flutter_inappwebview`-specific adapter exposing the FlareLane bridge in
/// shape that matches `flutter_inappwebview`'s `InAppWebView` widget slots
/// (`initialUserScripts`, `addJavaScriptHandler` via `onWebViewCreated`).
///
/// Example — alongside the customer's existing user scripts / handlers:
///
/// ```dart
/// InAppWebView(
///   initialUrlRequest: URLRequest(url: WebUri(url)),
///   initialUserScripts: UnmodifiableListView([
///     ...FlareLaneJavascriptInterface.initialUserScripts,
///     ...myUserScripts,
///   ]),
///   onWebViewCreated: (controller) {
///     controller.addJavaScriptHandler(
///       handlerName: FlareLaneJavascriptInterface.BRIDGE_NAME,
///       callback: FlareLaneJavascriptInterface.handlerCallback(controller),
///     );
///     myOnWebViewCreated(controller);
///   },
/// );
/// ```
class FlareLaneJavascriptInterface {
  /// Channel name constant — mirrors the native SDK's `BRIDGE_NAME`.
  // ignore: constant_identifier_names
  static const String BRIDGE_NAME = 'FlareLaneNativeBridge';

  /// `UserScript` list ready to plug into
  /// `InAppWebView(initialUserScripts: …)`. Installs the bridge shim at
  /// document start so the Web SDK detects `window.FlareLaneBridge` before
  /// any page scripts run.
  static UnmodifiableListView<UserScript> get initialUserScripts =>
      UnmodifiableListView<UserScript>([
        UserScript(
          source: _channelAdapter + BridgeCore.javaScriptInjection,
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
        ),
      ]);

  /// Returns a callback ready to plug into
  /// `controller.addJavaScriptHandler(handlerName: BRIDGE_NAME, callback: …)`.
  /// Each incoming message is routed through the FlareLane bridge core; if
  /// the core returns a JS string (e.g. the `syncDeviceData` response), it
  /// is evaluated back into the webview via the controller.
  static Future<void> Function(List<dynamic>) handlerCallback(
      InAppWebViewController controller) {
    return (List<dynamic> args) async {
      final String message =
          args.isNotEmpty && args.first is String ? args.first as String : '';
      if (message.isEmpty) return;
      final String? js = await BridgeCore.handle(message);
      if (js != null) {
        await controller.evaluateJavascript(source: js);
      }
    };
  }
}
