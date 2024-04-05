import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flarelane_flutter/flarelane_flutter.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

const FLARELANE_PROJECT_ID = 'FLARELANE_PROJECT_ID';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupFlareLane();

  // Test with FCM
  setupFCM();

  runApp(const MyApp());
}

Future<void> setupFlareLane() async {
  await FlareLane.shared.initialize(
    FLARELANE_PROJECT_ID,
    requestPermissionOnLaunch: false,
  );
}

Future<void> _fcmOnBackgroundMessage(RemoteMessage remoteMessage) async {
  print('FCM onBackgroundMessage: ${remoteMessage.toMap()}');
}

void _fcmOnMessageHandler(RemoteMessage remoteMessage) {
  print('FCM onMessage: ${remoteMessage.toMap()}');
}

void _fcmOnMessageOpenedApp(RemoteMessage remoteMessage) {
  print('FCM onMessageOpenedApp: ${remoteMessage.toMap()}');
}

Future<void> setupFCM() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  String? token = await messaging.getToken();
  print('FCM: token $token');
  FirebaseMessaging.onMessage.listen(_fcmOnMessageOpenedApp);
  FirebaseMessaging.onBackgroundMessage(_fcmOnBackgroundMessage);
  FirebaseMessaging.onMessageOpenedApp.listen(_fcmOnMessageOpenedApp);
}

const tags = {"age": 27, "gender": 'men'};

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

  @override
  void initState() {
    super.initState();

    FlareLane.shared.setNotificationClickedHandler((event) {
      setState(() {
        _clickedMessage =
            '✅ Message of clickedHandler\n${event.toString()}';
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

    setState(() {
      _resState = 'FlareLane initialized.';
    });
  }

  Future<void> toggleUserId() async {
    await FlareLane.shared
        .setUserId(_isSetUserId ? null : "myuser@flarelane.com");
    _isSetUserId = !_isSetUserId;
  }

  Future<void> toggleTags() async {
    if (!_isSetTags) {
      await FlareLane.shared.setTags(tags);
      _isSetTags = true;
    } else {
      await FlareLane.shared.deleteTags(tags.keys.toList());
      _isSetTags = false;
    }
  }

  Future<void> getTags() async {
    FlareLane.shared.getTags(print);
  }

  Future<void> getDeviceId() async {
    print(await FlareLane.shared.getDeviceId());
  }

  Future<void> trackEvent() async {
    await FlareLane.shared.trackEvent("test_event", {"test": "event"});
  }

  Future<void> subscribe() async {
    await FlareLane.shared.subscribe(true, (isSubscribed) {
      print(isSubscribed);
    });
  }

  Future<void> unsubscribe() async {
    await FlareLane.shared.unsubscribe((isSubscribed) {
      print(isSubscribed);
    });
  }

  Future<void> isSubscribed() async {
    final bool isSubscribed = await FlareLane.shared.isSubscribed();
    print(isSubscribed);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('FlareLane Example App'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: Text('$_resState\n\n$_clickedMessage')),
            OutlinedButton(
                onPressed: toggleUserId, child: const Text("TOGGLE USER ID")),
            OutlinedButton(
                onPressed: toggleTags, child: const Text("TOGGLE TAGS")),
            OutlinedButton(onPressed: getTags, child: const Text("PRINT TAGS")),
            OutlinedButton(
                onPressed: getDeviceId, child: const Text("PRINT DEVICE ID")),
            OutlinedButton(
                onPressed: trackEvent, child: const Text("TRACK EVENT")),
            OutlinedButton(
                onPressed: subscribe, child: const Text("SUBSCRIBE")),
            OutlinedButton(
                onPressed: unsubscribe, child: const Text("UNSUBSCRIBE")),
            OutlinedButton(
                onPressed: isSubscribed, child: const Text("ISSUBSCRIBED"))
          ],
        ),
      ),
    );
  }
}
