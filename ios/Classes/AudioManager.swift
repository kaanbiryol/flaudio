import Foundation
import AVFoundation

typealias DurationHandler = (Double, Double) -> Void
typealias VoidHandler = () -> Void
typealias StatusHandler = (AVPlayerItem.Status) -> Void
typealias ReadyHandler = (Double) -> Void

enum Channel {
    static let prepare = "prepare"
    static let play = "play"
    static let pause = "pause"
    static let playbackSpeed = "playbackSpeed"
    static let seek = "seek"
    static let seekTo = "seekTo"
    static let duration = "duration"
    static let dispose = "dispose"
}

enum Event {
    static let onStart = "onStart"
    static let onPause = "onStart"
    static let onTick = "onTick"
}


protocol Playable {
    var player: AVPlayer { get }
    var duration: Float64 { get }
    var observer: AVPlayerObserver { get }
    func prepare(_ urlString: String, onTickHandler: @escaping DurationHandler, onReadyHandler: @escaping ReadyHandler)
    func play(onPlayHandler: @escaping VoidHandler)
    func pause(onPauseHandler: @escaping VoidHandler)
    func playbackSpeed(to rate: Float)
    func seek(by seconds: Double)
    func seek(to seconds: Double)
    func dispose()
}

protocol PlayableEvent {

}

protocol AudioManagerProtocol: Playable, PlayableEvent {}

public class AudioManager: AudioManagerProtocol {
    
    static var shared: AudioManager = AudioManager()
    
    var duration: Float64 {
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
        player = AVPlayer(customURL: url, observer: observer)
        observer.addPeriodicTimeObserver(to: player, onTickHandler)
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
    
    func seek(by seconds: Double) {
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let soughtTime = currentTime + Float64(seconds)
        let time: CMTime = CMTimeMake(value: Int64(soughtTime * 1000 as Float64), timescale: 1000)
        player.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
    }
    
    func seek(to seconds: Double) {
        guard seconds < duration else { return }
        let time = CMTime(seconds: Double(seconds), preferredTimescale: 1000)
        player.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
    }
    
    func dispose() {
        player.pause()
        player.replaceCurrentItem(with: nil)
        observer.dispose(player)
    }

}