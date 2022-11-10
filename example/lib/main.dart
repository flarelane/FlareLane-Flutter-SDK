import 'dart:async';

import 'package:flarelane_flutter/flarelane_flutter.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
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
    initFlareLane();
  }

  Future<void> initFlareLane() async {
    if (!mounted) return;
    await FlareLane.shared.setLogLevel(LogLevel.verbose);

    await FlareLane.shared.initialize('a43cdc82-0ea5-4fdd-aebc-1940fe99b6c3');

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

  Future<void> getDeviceId() async {
    print(await FlareLane.shared.getDeviceId());
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
            OutlinedButton(
                onPressed: getDeviceId, child: const Text("PRINT DEVICE ID"))
          ],
        ),
      ),
    );
  }
}
