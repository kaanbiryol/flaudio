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
}

class Event {
  static const onStart = "onStart";
  static const onPause = "onPause";
  static const onTick = "onTick";
}

enum PlayerState { PLAYING, PAUSED }

class FLAudio {
  final StreamController<PlayerState> _stateController =
      new StreamController.broadcast();

  MethodChannel _methodChannel = const MethodChannel('flaudio');

  FLAudio() {
    _methodChannel.setMethodCallHandler(_playerStateChanged);
  }

  Future<void> prepare(String url) async {
    return await _methodChannel.invokeMethod(ChannelMethod.prepare, url);
  }

  Future<void> play() async {
    return await _methodChannel.invokeMethod(ChannelMethod.play);
  }

  Future<void> pause() async {
    return await _methodChannel.invokeMethod(ChannelMethod.pause);
  }

  Future<void> playbackSpeed(double speed) async {
    return await _methodChannel.invokeMethod(
        ChannelMethod.playbackSpeed, speed);
  }

  Future<void> seek(double seconds) async {
    return await _methodChannel.invokeMethod(ChannelMethod.seek, seconds);
  }

  Stream<PlayerState> get onPlayerStateChanged => _stateController.stream;

  Future<void> _playerStateChanged(MethodCall call) async {
    switch (call.method) {
      case Event.onStart:
        _stateController.add(PlayerState.PLAYING);
        break;
      case Event.onPause:
        _stateController.add(PlayerState.PAUSED);
        break;
      case Event.onTick:
        print("TODO" + call.arguments.toString());
        break;
      default:
        throw new ArgumentError('not supported channel method ${call.method} ');
    }
  }
}
