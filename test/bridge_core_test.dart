import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
// Internal — pinning the routing/injection contract that the adapters rely on.
import 'package:flarelane_flutter/src/bridge_core.dart';

/// Pins the JSON message routing + injection script shape that the adapters
/// (`lib/adapters/webview_flutter.dart`, `lib/adapters/flutter_inappwebview.dart`)
/// rely on. The Web SDK expects this exact contract.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('com.flarelane.flutter/methods');
  final List<MethodCall> calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      calls.add(call);
      if (call.method == '_webViewSyncPayload') {
        return <String, dynamic>{
          'projectId': 'P',
          'deviceId': 'D',
          'userId': 'U',
        };
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('BridgeCore.handle', () {
    test('syncDeviceData returns callback JS with the four canonical fields',
        () async {
      final String? js =
          await BridgeCore.handle(jsonEncode({'method': 'syncDeviceData'}));

      expect(js, isNotNull);
      expect(js, startsWith('FlareLane.syncDeviceDataCallback('));
      expect(js, endsWith(');'));

      final String jsonString = js!
          .replaceFirst('FlareLane.syncDeviceDataCallback(', '')
          .replaceFirst(RegExp(r'\);\s*$'), '');
      final Map<String, dynamic> payload = jsonDecode(jsonString) as Map<String, dynamic>;
      expect(payload['projectId'], equals('P'));
      expect(payload['deviceId'], equals('D'));
      expect(payload['userId'], equals('U'));
      expect(payload['platform'], anyOf(equals('ios'), equals('android')));
      expect(calls.where((c) => c.method == '_webViewSyncPayload'), hasLength(1));
    });

    test(
        'syncDeviceData still emits a callback with null identifiers when native returns all nulls',
        () async {
      // Native (iOS/Android) sends an all-null map when the SDK hasn't
      // resolved identifiers yet (pre-init / pre-handshake). The Web SDK
      // still expects a syncDeviceDataCallback invocation so it can react
      // to "no identifiers yet" instead of waiting indefinitely.
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
        calls.add(call);
        if (call.method == '_webViewSyncPayload') {
          return <String, dynamic>{
            'projectId': null,
            'deviceId': null,
            'userId': null,
          };
        }
        return null;
      });

      final String? js =
          await BridgeCore.handle(jsonEncode({'method': 'syncDeviceData'}));

      expect(js, isNotNull);
      final String jsonString = js!
          .replaceFirst('FlareLane.syncDeviceDataCallback(', '')
          .replaceFirst(RegExp(r'\);\s*$'), '');
      final Map<String, dynamic> payload =
          jsonDecode(jsonString) as Map<String, dynamic>;
      expect(payload['projectId'], isNull);
      expect(payload['deviceId'], isNull);
      expect(payload['userId'], isNull);
      expect(payload['platform'], anyOf(equals('ios'), equals('android')));
    });

    test('setUserId forwards the userId to the native channel', () async {
      final String? js = await BridgeCore.handle(
        jsonEncode({'method': 'setUserId', 'userId': 'user-1'}),
      );

      expect(js, isNull);
      expect(calls.where((c) => c.method == 'setUserId'), hasLength(1));
    });

    test('setTags forwards the tags map to the native channel', () async {
      await BridgeCore.handle(jsonEncode({
        'method': 'setTags',
        'tags': {'a': 'b'},
      }));

      expect(calls.where((c) => c.method == 'setTags'), hasLength(1));
    });

    test('trackEvent forwards type and optional data', () async {
      await BridgeCore.handle(jsonEncode({
        'method': 'trackEvent',
        'type': 'purchase',
        'data': {'sku': 'X'},
      }));

      expect(calls.where((c) => c.method == 'trackEvent'), hasLength(1));
    });

    test('setUserAttributes forwards attributes', () async {
      await BridgeCore.handle(jsonEncode({
        'method': 'setUserAttributes',
        'attributes': {'name': 'Test'},
      }));

      expect(calls.where((c) => c.method == 'setUserAttributes'), hasLength(1));
    });

    test('unknown method is ignored (no native call, no throw)', () async {
      final String? js =
          await BridgeCore.handle(jsonEncode({'method': 'somethingNew'}));
      expect(js, isNull);
    });

    test('malformed JSON does not throw', () async {
      final String? js = await BridgeCore.handle('{not json');
      expect(js, isNull);
    });

    test('missing method is ignored', () async {
      final String? js = await BridgeCore.handle(jsonEncode({'foo': 'bar'}));
      expect(js, isNull);
      expect(calls, isEmpty);
    });
  });

  group('BridgeCore.javaScriptInjection', () {
    test('targets the standard FlareLaneNativeBridge channel', () {
      expect(BridgeCore.javaScriptInjection,
          contains('window.FlareLaneNativeBridge'));
    });

    test('exposes window.FlareLaneBridge with the five bridge methods', () {
      const script = BridgeCore.javaScriptInjection;
      expect(script, contains('window.FlareLaneBridge'));
      for (final method in const [
        'syncDeviceData',
        'setUserId',
        'setTags',
        'trackEvent',
        'setUserAttributes',
      ]) {
        expect(script, contains(method));
      }
    });

    test('does not install displayInApp on the bridge', () {
      // Matches the native Android/iOS bridge surface — the Web SDK handles
      // in-app rendering inside the webview itself.
      expect(BridgeCore.javaScriptInjection,
          isNot(matches(RegExp(r'displayInApp\s*:'))));
    });

    test('does not install window.webkit.messageHandlers shim', () {
      expect(BridgeCore.javaScriptInjection,
          isNot(contains('window.webkit')));
    });

    test('is idempotent (guarded by __flareLaneBridgeInstalled)', () {
      expect(BridgeCore.javaScriptInjection,
          contains('__flareLaneBridgeInstalled'));
    });
  });
}
