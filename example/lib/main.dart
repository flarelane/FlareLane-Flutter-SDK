import 'dart:async';

import 'package:flarelane_flutter/flarelane_flutter.dart';
import 'package:flutter/material.dart';

import 'webview_bridge_demo.dart';
import 'webview_bridge_inappwebview_demo.dart';

const FLARELANE_PROJECT_ID = 'a43cdc82-0ea5-4fdd-aebc-1940fe99b6c3';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupFlareLane();

  runApp(const MyApp());
}

Future<void> setupFlareLane() async {
  await FlareLane.shared.initialize(
    FLARELANE_PROJECT_ID,
    requestPermissionOnLaunch: false,
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _resState = '';
  String _clickedMessage = '';
  bool _isSetUserId = false;
  bool _isSubscribed = false;
  bool _isSetTags = false;
  bool _isSetUserAttributes = false;
  bool _isSubscribedState = false;

  @override
  void initState() {
    super.initState();

    FlareLane.shared.setNotificationClickedHandler((notification) {
      setState(() {
        // `clickedButtonIndex` is the source of truth for "was a button
        // tapped?" — `clickedButton` can be null even on a button click when
        // native sent an out-of-range index (see FlareLaneNotification docs).
        final btnIndex = notification.clickedButtonIndex;
        final btn = notification.clickedButton;
        final btnLine = btnIndex != null
            ? '\nclickedButton: ${btn?.label ?? "(out-of-range)"} (index=$btnIndex) link=${btn?.link ?? "-"}'
            : '\nclickedButton: (body click)';
        _clickedMessage = '✅ Message of clickedHandler\n'
            '${notification.toString()}'
            '$btnLine'
            '\nclickedUrl: ${notification.clickedUrl ?? "-"}';
      });
    });

    FlareLane.shared.setNotificationForegroundReceivedHandler((event) {
      setState(() {
        _clickedMessage =
            '✅ Message of foregroundReceivedHandler\n${event.notification.toString()}';
      });

      if (event.notification.data?["dismiss_foreground_notification"] ==
          "true") {
        return;
      }

      event.display();
    });

    FlareLane.shared.setInAppMessageActionHandler((iam, actionId) {
      var message =
          '✅ Message of setInAppMessageActionHandler\n${iam.toString()}\nactionId:${actionId}';
      print(message);
      setState(() {
        _clickedMessage = message;
      });
    });

    FlareLane.shared.displayInApp("home");

    // Sync initial subscribe-toggle label with the actual SDK state so the
    // first tap doesn't appear inverted (e.g. already-subscribed device showing
    // "set"). isSubscribed is one-shot; the toggle handlers keep it in sync
    // after that.
    FlareLane.shared.isSubscribed().then((subscribed) {
      if (mounted) setState(() => _isSubscribedState = subscribed);
    });

    setState(() {
      _resState = 'FlareLane initialized.';
    });
  }

  Future<void> toggleUserId() async {
    await FlareLane.shared
        .setUserId(_isSetUserId ? null : "myuser@flarelane.com");
    setState(() => _isSetUserId = !_isSetUserId);
  }

  Future<void> toggleTags() async {
    if (!_isSetTags) {
      await FlareLane.shared.setTags({"age": 27, "gender": 'men'});
      setState(() => _isSetTags = true);
    } else {
      await FlareLane.shared.setTags({"age": null, "gender": null});
      setState(() => _isSetTags = false);
    }
  }

  Future<void> getDeviceId() async {
    print(await FlareLane.shared.getDeviceId());
  }

  Future<void> trackEvent() async {
    await FlareLane.shared.trackEvent("test_event", {"test": "event"});
  }

  Future<void> toggleSubscribe() async {
    if (!_isSubscribedState) {
      await FlareLane.shared.subscribe(true, (subscribed) {
        print('subscribe -> $subscribed');
        setState(() => _isSubscribedState = subscribed);
      });
    } else {
      await FlareLane.shared.unsubscribe((subscribed) {
        print('unsubscribe -> $subscribed');
        setState(() => _isSubscribedState = subscribed);
      });
    }
  }

  Future<void> isSubscribed() async {
    final bool isSubscribed = await FlareLane.shared.isSubscribed();
    print(isSubscribed);
  }

  Future<void> displayInApp() async {
    FlareLane.shared.displayInApp("home", {"test": "data", "test2": 123});
  }

  Future<void> toggleUserAttributes() async {
    if (_isSetUserAttributes) {
      await FlareLane.shared.setUserAttributes({
        "name": null,
        "email": null,
        "phoneNumber": null,
        "dob": null,
        "timeZone": null,
        "country": null,
        "language": null,
      });
      setState(() => _isSetUserAttributes = false);
    } else {
      await FlareLane.shared.setUserAttributes({
        "name": "Test User",
        "email": "test@example.com",
        "phoneNumber": "+821012345678",
        "dob": "1990-01-01",
        "timeZone": "Asia/Seoul",
        "country": "KR",
        "language": "ko",
      });
      setState(() => _isSetUserAttributes = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('FlareLane Example App'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(child: Text('$_resState\n\n$_clickedMessage')),
              OutlinedButton(
                  onPressed: toggleUserId,
                  child: Text("TOGGLE USER ID (${_isSetUserId ? "del" : "set"})")),
              OutlinedButton(
                  onPressed: toggleTags,
                  child: Text("TOGGLE TAGS (${_isSetTags ? "del" : "set"})")),
              OutlinedButton(
                  onPressed: toggleUserAttributes,
                  child: Text(
                      "TOGGLE USER ATTRIBUTES (${_isSetUserAttributes ? "del" : "set"})")),
              OutlinedButton(
                  onPressed: toggleSubscribe,
                  child: Text("TOGGLE SUBSCRIBE (${_isSubscribedState ? "del" : "set"})")),
              OutlinedButton(
                  onPressed: getDeviceId, child: const Text("PRINT DEVICE ID")),
              OutlinedButton(
                  onPressed: trackEvent, child: const Text("TRACK EVENT")),
              OutlinedButton(
                  onPressed: isSubscribed, child: const Text("ISSUBSCRIBED")),
              OutlinedButton(
                  onPressed: displayInApp, child: const Text("DISPLAY INAPP")),
              const Padding(
                padding: EdgeInsets.only(top: 12, bottom: 4),
                child: Text(
                  'WebView Bridge',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              OutlinedButton(
                  onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const WebViewBridgeDemo(
                            projectId: FLARELANE_PROJECT_ID,
                          ),
                        ),
                      ),
                  child: const Text("webview_flutter")),
              OutlinedButton(
                  onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const WebViewBridgeInAppWebViewDemo(
                            projectId: FLARELANE_PROJECT_ID,
                          ),
                        ),
                      ),
                  child: const Text("flutter_inappwebview"))
            ],
          ),
        ),
      ),
    );
  }
}
