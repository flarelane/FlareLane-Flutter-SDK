import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../flarelane_flutter.dart';

/// Internal bridge core shared by the webview library adapters under
/// `lib/adapters/`. Not part of the package's public API — consumers should
/// import the adapter that matches their webview library instead.
///
/// Exposes:
///   * [javaScriptInjection] — JS snippet that installs `window.FlareLaneBridge`.
///   * [handle] — routes one JSON message from the webview into the native
///     FlareLane SDK and returns an optional response JS string the caller
///     evaluates back into the webview (used by `syncDeviceData`).
///
/// Adapters layer on top of this with library-specific message-channel
/// wrapping (e.g. `flutter_inappwebview.callHandler` vs `webview_flutter`'s
/// `addJavaScriptChannel`).
class BridgeCore {
  BridgeCore._();

  static const MethodChannel _channel =
      MethodChannel('com.flarelane.flutter/methods');

  /// JS snippet that installs `window.FlareLaneBridge`. Idempotent — safe to
  /// inject multiple times (guarded by a flag on `window`).
  static const String javaScriptInjection = _injectionScript;

  /// Route a JSON message from the webview channel into the native SDK.
  /// Returns a JS string to evaluate back into the webview (only for the
  /// `syncDeviceData` response), or `null` otherwise. Never throws.
  static Future<String?> handle(String message) async {
    try {
      final dynamic raw = jsonDecode(message);
      if (raw is! Map) {
        debugPrint('[FlareLane] WebView bridge ignored non-object message');
        return null;
      }
      final Map<String, dynamic> body = raw.cast<String, dynamic>();
      final String? method = body['method'] as String?;
      if (method == null) {
        debugPrint('[FlareLane] WebView bridge message missing "method"');
        return null;
      }

      switch (method) {
        case 'syncDeviceData':
          return await _buildSyncDeviceDataCallback();
        case 'setUserId':
          await FlareLane.shared.setUserId(body['userId'] as String?);
          return null;
        case 'setTags':
          final Map? tags = body['tags'] as Map?;
          if (tags != null) {
            await FlareLane.shared.setTags(tags.cast<String, Object?>());
          }
          return null;
        case 'trackEvent':
          final String? type = body['type'] as String?;
          if (type == null) {
            debugPrint('[FlareLane] trackEvent missing "type"');
            return null;
          }
          final Map? data = body['data'] as Map?;
          await FlareLane.shared
              .trackEvent(type, data?.cast<String, Object>());
          return null;
        case 'setUserAttributes':
          final Map? attributes = body['attributes'] as Map?;
          if (attributes != null) {
            await FlareLane.shared
                .setUserAttributes(attributes.cast<String, Object?>());
          }
          return null;
        default:
          debugPrint('[FlareLane] WebView bridge unknown method: $method');
          return null;
      }
    } catch (e) {
      debugPrint('[FlareLane] WebView bridge handle failed: $e');
      return null;
    }
  }

  static Future<String?> _buildSyncDeviceDataCallback() async {
    try {
      final Map<dynamic, dynamic>? raw =
          await _channel.invokeMethod<Map>('_webViewSyncPayload');
      final Map<String, dynamic> payload =
          raw?.cast<String, dynamic>() ?? <String, dynamic>{};
      // Plugin returns projectId/deviceId/userId; platform is filled here so
      // the native plugin handler stays generic.
      payload['platform'] = Platform.isIOS ? 'ios' : 'android';
      return 'FlareLane.syncDeviceDataCallback(${jsonEncode(payload)});';
    } catch (e) {
      debugPrint('[FlareLane] _webViewSyncPayload failed: $e');
      return null;
    }
  }
}

// `window.FlareLaneBridge` mirrors the native Android JavascriptInterface
// surface — the Web SDK detects it and forwards calls. We intentionally do
// NOT install `window.webkit.messageHandlers.FlareLaneBridge` (the iOS hook).
// The Web SDK calls both paths unconditionally; installing both would deliver
// every action twice.
//
// `displayInApp` is intentionally omitted to match the native Android/iOS
// SDK bridges: the Web SDK renders in-app messages inside the webview itself
// using device data synced via `syncDeviceData`.
const String _injectionScript = '''
(function () {
  if (window.__flareLaneBridgeInstalled) return;
  window.__flareLaneBridgeInstalled = true;

  function post(payload) {
    try {
      var ch = window.FlareLaneNativeBridge;
      if (ch && typeof ch.postMessage === 'function') {
        ch.postMessage(JSON.stringify(payload));
      }
    } catch (e) {}
  }

  window.FlareLaneBridge = {
    syncDeviceData: function () { post({ method: 'syncDeviceData' }); },
    setUserId: function (userId) { post({ method: 'setUserId', userId: userId }); },
    setTags: function (jsonString) {
      var tags = {}; try { tags = JSON.parse(jsonString); } catch (e) {}
      post({ method: 'setTags', tags: tags });
    },
    trackEvent: function (type, jsonString) {
      var data = null; if (jsonString) { try { data = JSON.parse(jsonString); } catch (e) {} }
      post({ method: 'trackEvent', type: type, data: data });
    },
    setUserAttributes: function (jsonString) {
      var attributes = {}; try { attributes = JSON.parse(jsonString); } catch (e) {}
      post({ method: 'setUserAttributes', attributes: attributes });
    }
  };
})();
''';
