import 'dart:async';
import 'package:flutter/services.dart';

class ChannelMethod {
  static const prepare = "prepare";
  static const play = "play";
  static const playbackSpeed = "playbackSpeed";
  static const seek = "seek";
}

class FLAudio {
  static const MethodChannel _channel = const MethodChannel('flaudio');

  static Future<void> prepare(String url) async {
    return await _channel.invokeMethod(ChannelMethod.prepare, url);
  }

  static Future<void> play() async {
    print("play");
    return await _channel.invokeMethod(ChannelMethod.play);
  }

  static Future<void> playbackSpeed(double speed) async {
    return await _channel.invokeMethod(ChannelMethod.playbackSpeed, speed);
  }

  static Future<void> seek(double seconds) async {
    return await _channel.invokeMethod(ChannelMethod.seek, seconds);
  }
}
