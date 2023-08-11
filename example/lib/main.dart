import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flarelane_flutter/flarelane_flutter.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'firebase_options.dart';

const FLARELANE_PROJECT_ID = 'FLARELANE_PROJECT_ID';
const ONESIGNAL_PROJECT_ID = "ONESIGNAL_PROJECT_ID";

Future<void> _fcmOnBackgroundMessage(RemoteMessage remoteMessage) async {
  print('FCM onBackgroundMessage: ${remoteMessage.toMap()}');
}

void _fcmOnMessageHandler(RemoteMessage remoteMessage) {
  print('FCM onMessage: ${remoteMessage.toMap()}');
}

void _fcmOnMessageOpenedApp(RemoteMessage remoteMessage) {
  print('FCM onMessageOpenedApp: ${remoteMessage.toMap()}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupFCM();
  await setupOS();
  await setupFlareLane();

  runApp(const MyApp());
}

Future<void> setupFCM() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  String? token = await messaging.getToken();
  print('FCM: token $token');
  FirebaseMessaging.onMessage.listen(_fcmOnMessageOpenedApp);
  FirebaseMessaging.onBackgroundMessage(_fcmOnBackgroundMessage);
  FirebaseMessaging.onMessageOpenedApp.listen(_fcmOnMessageOpenedApp);
}

Future<void> setupOS() async {
  OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
  OneSignal.shared.setAppId(ONESIGNAL_PROJECT_ID);
  OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
    print("OneSignal: Accepted permission: $accepted");
  });
  OneSignal.shared.setNotificationWillShowInForegroundHandler(
      (OSNotificationReceivedEvent event) {
    print('"OneSignal: setNotificationWillShowInForegroundHandler: ${event}');
    event.complete(event.notification);
  });
  OneSignal.shared
      .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
    print('"OneSignal: setNotificationOpenedHandler: ${result}');
  });
}

Future<void> setupFlareLane() async {
  await FlareLane.shared.setLogLevel(LogLevel.verbose);
  await FlareLane.shared.initialize(FLARELANE_PROJECT_ID);
}

const tags = {"age": 27, "gender": 'men'};

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _resState = '';
  String _convertedMessage = '';
  bool _isSetUserId = false;
  bool _isSubscribed = false;
  bool _isSetTags = false;

  @override
  void initState() {
    super.initState();

    FlareLane.shared.setNotificationConvertedHandler((notification) {
      setState(() {
        _convertedMessage =
            '✅ Activated convertedHandler\n${notification.toString()}';
      });
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

  Future<void> toggleIsSubscribed() async {
    await FlareLane.shared.setIsSubscribed(_isSubscribed);
    _isSubscribed = !_isSubscribed;
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
            Center(child: Text('$_resState\n\n$_convertedMessage')),
            OutlinedButton(
                onPressed: toggleUserId, child: const Text("TOGGLE USER ID")),
            OutlinedButton(
                onPressed: toggleIsSubscribed,
                child: const Text("TOGGLE IS SUBSCRIBED")),
            OutlinedButton(
                onPressed: toggleTags, child: const Text("TOGGLE TAGS")),
            OutlinedButton(onPressed: getTags, child: const Text("PRINT TAGS")),
            OutlinedButton(
                onPressed: getDeviceId, child: const Text("PRINT DEVICE ID")),
            OutlinedButton(
                onPressed: trackEvent, child: const Text("TRACK EVENT"))
          ],
        ),
      ),
    );
  }
}
