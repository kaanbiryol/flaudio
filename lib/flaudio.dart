import 'dart:async';
import 'package:flutter/services.dart';

typedef VoidHandler = void Function();
typedef IntHandler = void Function(int value);
typedef PlayerStateHandler = void Function(PlayerState state);

class ChannelMethod {
  static const prepare = "prepare";
  static const play = "play";
  static const pause = "pause";
  static const playbackSpeed = "playbackSpeed";
  static const seek = "seek";
  static const seekTo = "seekTo";
  static const duration = "duration";
  static const dispose = "dispose";
}

class Event {
  static const onStart = "onStart";
  static const onPause = "onPause";
  static const onTick = "onTick";
}

class PlayerTime {
  Duration currentTime;
  Duration duration;
  PlayerTime(this.currentTime, this.duration);
}

enum PlayerState { PLAYING, PAUSED }

class FLAudio {
  final StreamController<PlayerState> _stateController =
      new StreamController.broadcast();
  final StreamController<PlayerTime> _positionController =
      new StreamController.broadcast();

  MethodChannel _methodChannel = const MethodChannel('flaudio');

  FLAudio() {
    _methodChannel.setMethodCallHandler(_playerStateChanged);
  }

  Future<Duration> prepare(String url) async {
    double duration =
        await _methodChannel.invokeMethod(ChannelMethod.prepare, url);
    return Duration(seconds: duration.toInt());
  }

  Future<void> play() async {
    return await _methodChannel.invokeMethod(ChannelMethod.play);
  }

  Future<void> pause() async {
    return await _methodChannel.invokeMethod(ChannelMethod.pause);
  }

  Future<void> setPlaybackSpeed(double speed) async {
    return await _methodChannel.invokeMethod(
        ChannelMethod.playbackSpeed, speed);
  }

  Future<void> seek(double seconds) async {
    return await _methodChannel.invokeMethod(ChannelMethod.seek, seconds);
  }

  Future<void> seekTo(double seconds) async {
    return await _methodChannel.invokeMethod(ChannelMethod.seekTo, seconds);
  }

  Future<Duration> get duration async {
    double seconds = await _methodChannel.invokeMethod(ChannelMethod.duration);
    return Duration(seconds: seconds.toInt());
  }

  Future<void> dispose() async {
    return await _methodChannel.invokeMethod(ChannelMethod.dispose);
  }

  Stream<PlayerState> get onPlayerStateChanged => _stateController.stream;
  Stream<PlayerTime> get onTick => _positionController.stream;

  Future<void> _playerStateChanged(MethodCall call) async {
    switch (call.method) {
      case Event.onStart:
        _stateController.add(PlayerState.PLAYING);
        break;
      case Event.onPause:
        _stateController.add(PlayerState.PAUSED);
        break;
      case Event.onTick:
        Map argumentsMap = call.arguments;
        double currentTimeInSeconds = argumentsMap["time"];
        double durationInSeconds = argumentsMap["duration"];
        Duration currentTime = Duration(seconds: currentTimeInSeconds.toInt());
        Duration duration = Duration(seconds: durationInSeconds.toInt());
        PlayerTime playerTime = PlayerTime(currentTime, duration);
        _positionController.add(playerTime);
        break;
      default:
        throw new ArgumentError('not supported channel method ${call.method} ');
    }
  }
}
