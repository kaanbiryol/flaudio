import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flaudio/flaudio.dart';
import 'package:example/double+extension.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final player = FLAudio();

  String currentTimeString = "NOT STARTED";
  double playbackSpeed = 1.0;
  int durationInSeconds = 1;
  double _currentTimeSliderValue = 0;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    try {
      player.onPlayerStateChanged.listen((state) => {print(state)});
      player.onTick.listen((playerTime) => {
            this.setState(() => {
                  this._currentTimeSliderValue =
                      playerTime.currentTime.inSeconds.toDouble(),
                  this.currentTimeString =
                      playerTime.currentTime.inSeconds.toString() +
                          " : " +
                          playerTime.duration.inSeconds.toString()
                })
          });
    } on PlatformException {
      print("error");
    }

    var duration = await player.prepare(
        "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3");
    this.durationInSeconds = duration.inSeconds;
    print("duration" + durationInSeconds.toString());
  }

  double currentTimeToSliderValue(int seconds) {
    return seconds / durationInSeconds;
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
            Column(
              children: <Widget>[
                Text(currentTimeString),
                Slider(
                    max: durationInSeconds.toDouble(),
                    min: 0,
                    value: _currentTimeSliderValue,
                    onChangeEnd: (value) {
                      player.seekTo(value);
                    },
                    onChanged: (value) => {
                          setState(() {
                            _currentTimeSliderValue = value;
                          })
                        }),
              ],
            ),
            FlatButton(onPressed: () => {player.play()}, child: Text("Play")),
            FlatButton(onPressed: () => player.pause(), child: Text("Pause")),
            FlatButton(
                onPressed: () => player.seek(10), child: Text("Seek forward")),
            FlatButton(
                onPressed: () => player.seek(-10),
                child: Text("Seek backward")),
            Column(
              children: <Widget>[
                Text("Playback speed" + playbackSpeed.toString()),
                Slider(
                    max: 2,
                    min: 0.5,
                    value: playbackSpeed,
                    onChanged: (value) => {
                          setState(() {
                            playbackSpeed = value.toPrecision(1);
                            player.setPlaybackSpeed(playbackSpeed);
                          })
                        }),
              ],
            )
          ],
        )),
      ),
    );
  }
}
