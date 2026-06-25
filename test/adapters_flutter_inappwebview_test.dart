import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flarelane_flutter/adapters/flutter_inappwebview.dart';

/// Spec for the `flutter_inappwebview` adapter
/// (`flarelane_flutter/adapters/flutter_inappwebview.dart`).
///
/// Pins the public shape and the user-script injection timing, since the
/// timing (AT_DOCUMENT_START) is what lets the Web SDK detect
/// `window.FlareLaneBridge` before its own scripts evaluate.
void main() {
  group('FlareLaneJavascriptInterface (flutter_inappwebview)', () {
    test('BRIDGE_NAME matches the standard channel name', () {
      expect(FlareLaneJavascriptInterface.BRIDGE_NAME,
          equals('FlareLaneNativeBridge'));
    });

    test('initialUserScripts contains exactly one document-start script', () {
      final scripts = FlareLaneJavascriptInterface.initialUserScripts;
      expect(scripts, hasLength(1));
      expect(scripts.first.injectionTime,
          equals(UserScriptInjectionTime.AT_DOCUMENT_START));
    });

    test('initialUserScripts source installs the FlareLaneBridge shim and the flutter_inappwebview channel adapter', () {
      final source = FlareLaneJavascriptInterface.initialUserScripts.first.source;
      // bridge shim (from core javaScriptInjection)
      expect(source, contains('window.FlareLaneBridge'));
      // channel adapter for flutter_inappwebview's callHandler API
      expect(source, contains('window.flutter_inappwebview.callHandler'));
      expect(source, contains('FlareLaneNativeBridge'));
    });

    test('handlerCallback is a factory returning a function', () {
      // Just confirm the factory exists — calling it requires an
      // InAppWebViewController which can't be instantiated outside a real
      // webview. Functional behavior is exercised by the bridge-core tests
      // + the example app e2e flow.
      expect(FlareLaneJavascriptInterface.handlerCallback, isA<Function>());
    });
  });
}
