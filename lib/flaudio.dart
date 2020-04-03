import 'dart:async';
import 'package:flutter/services.dart';

class ChannelMethod {
  static const prepare = "prepare";
  static const play = "play";
}

class FLAudio {
  static const MethodChannel _channel = const MethodChannel('flaudio');

  static Future<void> prepare(String url) async {
    return await _channel.invokeMethod(ChannelMethod.prepare, url);
  }

  static Future<String> get play async {
    final String version = await _channel.invokeMethod(ChannelMethod.play);
    return version;
  }
}
