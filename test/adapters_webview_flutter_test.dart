import 'package:flutter_test/flutter_test.dart';
import 'package:flarelane_flutter/adapters/webview_flutter.dart';

/// Spec for the `webview_flutter` adapter
/// (`flarelane_flutter/adapters/webview_flutter.dart`).
///
/// The adapter is a thin facade that delegates to the bridge core; tests
/// here pin the public shape (constant name, factory signatures) so the
/// surface stays stable. Functional behavior of `onMessageReceived` /
/// `onPageStarted` is covered by the bridge-core tests + e2e example apps,
/// since constructing a real `WebViewController` requires platform setup.
void main() {
  group('FlareLaneJavascriptInterface (webview_flutter)', () {
    test('BRIDGE_NAME matches the standard channel name', () {
      expect(FlareLaneJavascriptInterface.BRIDGE_NAME,
          equals('FlareLaneNativeBridge'));
    });

    test('exposes the three documented members for slot wiring', () {
      // Symbol-level presence check — the adapter class must keep these
      // three members exactly to keep the README snippets compilable.
      expect(FlareLaneJavascriptInterface.BRIDGE_NAME, isA<String>());
      expect(FlareLaneJavascriptInterface.onMessageReceived, isA<Function>());
      expect(FlareLaneJavascriptInterface.onPageStarted, isA<Function>());
    });
  });
}
