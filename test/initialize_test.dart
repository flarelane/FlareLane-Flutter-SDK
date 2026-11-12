import 'package:flarelane_flutter/flarelane_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pins the `initialize` method-channel arguments the native plugins read.
/// The plugin only forwards `region`; validation lives in the native SDKs.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('com.flarelane.flutter/methods');
  final List<MethodCall> calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      calls.add(call);
      return true;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('initialize sends a null region when it is omitted', () async {
    await FlareLane.shared.initialize('P');

    final MethodCall call = calls.single;
    final Map<dynamic, dynamic> args = call.arguments as Map<dynamic, dynamic>;
    expect(call.method, equals('initialize'));
    expect(args['projectId'], equals('P'));
    expect(args['requestPermissionOnLaunch'], isTrue);
    expect(args.containsKey('region'), isTrue);
    expect(args['region'], isNull);
  });

  test('initialize forwards the region exactly as given', () async {
    await FlareLane.shared.initialize('P', region: ' KR');

    final Map<dynamic, dynamic> args =
        calls.single.arguments as Map<dynamic, dynamic>;
    expect(args['region'], equals(' KR'));
  });
}
