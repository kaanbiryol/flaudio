import Flutter
import UIKit

public class SwiftFLAudioPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flaudio", binaryMessenger: registrar.messenger())
        let instance = SwiftFLAudioPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments
        switch call.method {
        case Channel.prepare:
            guard let urlString = arguments as? String else { return }
            AudioManager.shared.prepare(urlString)
        case Channel.play:
        print("play2");
            AudioManager.shared.play()
        case Channel.playbackSpeed:
            guard let speed = arguments as? Float else { return }
            AudioManager.shared.playbackSpeed(to: speed)
        case Channel.seek:
            guard let seconds = arguments as? Int else { return }
            AudioManager.shared.seek(by: seconds)
        default:
            result("iOS " + UIDevice.current.systemVersion)
        }
    }
}