import 'dart:async';

import 'package:flarelane_flutter/flarelane_flutter.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _resState = '';
  String _convertedMessage = '';

  @override
  void initState() {
    super.initState();
    initFlareLane();
  }

  Future<void> initFlareLane() async {
    if (!mounted) return;
    await FlareLane.shared.setLogLevel(5);

    await FlareLane.shared.initialize('b9aa419c-f034-4861-8fb7-d1c0b7c3ecf8');

    FlareLane.shared.setNotificationConvertedHandler((notification) {
      setState(() {
        _convertedMessage =
            '✅ Activated convertedHandler\nid: ${notification.id}\ntitle: ${notification.title}\nbody: ${notification.body}\nurl: ${notification.url}';
      });
    });

    setState(() {
      _resState = 'FlareLane initialized';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('FlareLane Example App'),
        ),
        body: Center(
          child: Text('$_resState\n\n$_convertedMessage'),
        ),
      ),
    );
  }
}
