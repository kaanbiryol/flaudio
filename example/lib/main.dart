import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flaudio/flaudio.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    try {
      FLAudio.prepare(
          "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3");
      // FLAudio.playbackSpeed(4);
    } on PlatformException {
      print("error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
            child: Column(
          children: <Widget>[
            FlatButton(onPressed: () => FLAudio.play(), child: Text("Play")),
            FlatButton(
                onPressed: () => FLAudio.seek(10), child: Text("Seek forward")),
            FlatButton(
                onPressed: () => FLAudio.seek(-10),
                child: Text("Seek backward"))
          ],
        )),
      ),
    );
  }
}
