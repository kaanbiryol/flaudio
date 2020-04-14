import Flutter
import UIKit

public class SwiftFLAudioPlugin: NSObject, FlutterPlugin {
    
    let channel: FlutterMethodChannel!
    
    private init(_ channel: FlutterMethodChannel) {
        self.channel = channel
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flaudio", binaryMessenger: registrar.messenger())
        let instance = SwiftFLAudioPlugin(channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments
        switch call.method {
        case Channel.prepare:
            guard let urlString = arguments as? String else { return }
            AudioManager.shared.prepare(urlString, onTickHandler: { [weak self] (currentTime, duration) in
                self?.channel.invokeMethod(Event.onTick, arguments: ["time": currentTime, "duration": duration])
            }) { (duration) in
                result(duration)
            }
        case Channel.play:
            AudioManager.shared.play { [weak self] in
                self?.channel.invokeMethod(Event.onStart, arguments: nil)
            }
        case Channel.pause:
            AudioManager.shared.pause { [weak self] in
                self?.channel.invokeMethod(Event.onPause, arguments: nil)
            }
        case Channel.playbackSpeed:
            guard let speed = arguments as? Float else { return }
            AudioManager.shared.playbackSpeed(to: speed)
        case Channel.seek:
            guard let seconds = arguments as? Double else { return }
            AudioManager.shared.seek(by: seconds)
        case Channel.seekTo:
            guard let seconds = arguments as? Double else { return }
            AudioManager.shared.seek(to: seconds)
        case Channel.duration:
            result(AudioManager.shared.duration)
        case Channel.dispose:
            AudioManager.shared.dispose()
            result(nil)
        default:
            result("not supported channel method: " + call.method)
        }
    }
}
