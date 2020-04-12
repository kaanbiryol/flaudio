import Foundation
import AVFoundation

typealias DurationHandler = (Int, Int) -> Void
typealias VoidHandler = () -> Void
typealias StatusHandler = (AVPlayerItem.Status) -> Void
typealias ReadyHandler = (Int) -> Void

enum Channel {
    static let prepare = "prepare"
    static let play = "play"
    static let pause = "pause"
    static let playbackSpeed = "playbackSpeed"
    static let seek = "seek"
    static let duration = "duration"
}

enum Event {
    static let onStart = "onStart"
    static let onPause = "onStart"
    static let onTick = "onTick"
}


protocol Playable {
    var player: AVPlayer { get }
    var duration: Int { get }
    var observer: AVPlayerObserver { get }
    func prepare(_ urlString: String, onTickHandler: @escaping DurationHandler, onReadyHandler: @escaping ReadyHandler)
    func play(onPlayHandler: @escaping VoidHandler)
    func pause(onPauseHandler: @escaping VoidHandler)
    func playbackSpeed(to rate: Float)
    func seek(by seconds: Int)
    func dispose()
}

protocol PlayableEvent {
    
}

protocol AudioManagerProtocol: Playable, PlayableEvent {}

public class AudioManager: AudioManagerProtocol {
    
    static var shared: AudioManager = AudioManager()
    
    var duration: Int {
        return player.duration
    }
    
    private init() {}
    
    var player: AVPlayer = AVPlayer()
    var observer = AVPlayerObserver()
    
    func prepare(_ urlString: String, onTickHandler: @escaping DurationHandler, onReadyHandler: @escaping ReadyHandler) {
        guard let url = URL(string: urlString) else { return }
        observer.statusHandler = { [weak self] (status) in
            switch status {
            case .readyToPlay:
                guard let duration = self?.player.duration else { return }
                onReadyHandler(duration)
            default:
                print("error")
            }
        }
        observer.addPeriodicTimeObserver(to: player, onTickHandler)
        player = AVPlayer(customURL: url, observer: observer)
    }
    
    func play(onPlayHandler: @escaping VoidHandler) {
        player.play()
        onPlayHandler()
    }
    
    func pause(onPauseHandler: @escaping VoidHandler) {
        player.pause()
        onPauseHandler()
    }
    
    func playbackSpeed(to rate: Float) {
        player.rate = rate
    }
    
    func seek(by seconds: Int) {
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let soughtTime = currentTime + Float64(seconds)
        let time: CMTime = CMTimeMake(value: Int64(soughtTime * 1000 as Float64), timescale: 1000)
        player.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
    }
    
    func dispose() {
        observer.dispose(player)
    }

}

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
            guard let seconds = arguments as? Int else { return }
            AudioManager.shared.seek(by: seconds)
        case Channel.duration:
            result(AudioManager.shared.duration)
        default:
            result("not supported channel method: " + call.method)
        }
    }
}
