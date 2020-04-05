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
  final player = FLAudio();
  String currentTime = "NOT STARTED";

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    try {
      player.onPlayerStateChanged.listen((state) => {print(state)});
      player.prepare(
          "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3");
      player.onTick.listen((playerTime) => {
            this.setState(() => {
                  this.currentTime =
                      playerTime.currentTime.inSeconds.toString() +
                          " : " +
                          playerTime.duration.inSeconds.toString()
                })
          });
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
            Text(currentTime),
            FlatButton(onPressed: () => player.play(), child: Text("Play")),
            FlatButton(onPressed: () => player.pause(), child: Text("Pause")),
            FlatButton(
                onPressed: () => player.seek(10), child: Text("Seek forward")),
            FlatButton(
                onPressed: () => player.seek(-10),
                child: Text("Seek backward")),
            Slider(
                label: "Playback speed",
                max: 3,
                min: 0.5,
                value: 0.5,
                onChanged: (value) => {player.setPlaybackSpeed(value)})
          ],
        )),
      ),
    );
  }
}
