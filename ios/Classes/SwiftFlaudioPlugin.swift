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
            AudioManager.shared.play()
        default:
            result("iOS " + UIDevice.current.systemVersion)
        }
    }
}