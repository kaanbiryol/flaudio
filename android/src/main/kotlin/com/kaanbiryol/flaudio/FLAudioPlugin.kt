package com.kaanbiryol.flaudio

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

/** FLAudioPlugin */
class FLAudioPlugin: FlutterPlugin, MethodCallHandler {

  private lateinit var channel: MethodChannel

  constructor() {}

  constructor(channel: MethodChannel) {
    this.channel = channel
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    val channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "flaudio")
    channel.setMethodCallHandler(FLAudioPlugin(channel));
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "flaudio")
      channel.setMethodCallHandler(FLAudioPlugin(channel))
    }
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    val arguments = call.arguments
    when(call.method) {
      Channel.prepare -> {
        val urlString = arguments as? String ?: return
        AudioManager.instance.prepare(urlString, onTickHandler = { currentTime: Int, duration: Int ->
            channel.invokeMethod(Event.onTick, mapOf("time" to currentTime, "duration" to duration))
        } )
      }
      Channel.play -> {
        AudioManager.instance.play {
          channel.invokeMethod(Event.onStart, null)
        }
      }
      Channel.pause -> {
        AudioManager.instance.pause {
          channel.invokeMethod(Event.onPause, null)
        }
      }
      Channel.playbackSpeed -> {
        val speed = arguments as? Float ?: return
        AudioManager.instance.playbackSpeed(speed)
      }
      Channel.seek -> {
        val seconds = arguments as? Int ?: return
        AudioManager.instance.seek(seconds)
      }
      Channel.duration -> {
        result.success(AudioManager.instance.duration)
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
  }
}
