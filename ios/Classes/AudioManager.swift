
import Foundation
import AVFoundation

typealias IntHandler = (Int) -> Void
typealias VoidHandler = () -> Void

enum Channel {
    static let prepare = "prepare"
    static let play = "play"
    static let pause = "pause"
    static let playbackSpeed = "playbackSpeed"
    static let seek = "seek"
}

enum Event {
    static let onStart = "onStart"
    static let onPause = "onPause"
    static let onTick = "onTick"
}


protocol Playable {
    var player: AVPlayer { get }
    func prepare(_ urlString: String, onTickHandler: @escaping IntHandler)
    func play(onPlayHandler: @escaping VoidHandler)
    func pause(onPauseHandler: @escaping VoidHandler)
    func playbackSpeed(to rate: Float)
    func seek(by seconds: Int)
}

protocol PlayableEvent {
    func onTick(_ time: CMTime, _ onTickHandler: IntHandler)
}

protocol AudioManagerProtocol: Playable, PlayableEvent {}

public class AudioManager: AudioManagerProtocol {
    
    static var shared: AudioManager = AudioManager()
    
    private init() {}
    
    var player: AVPlayer = AVPlayer()
    private var timeObserverToken: Any?
    
    func prepare(_ urlString: String, onTickHandler: @escaping IntHandler) {
        removePeriodicTimeObserver()
        guard let url = URL(string: urlString) else { return }
        player = AVPlayer(url: url)
        addPeriodicTimeObserver(onTickHandler)
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
    
    func onTick(_ time: CMTime, _ onTickHandler: IntHandler) {
        let second = CMTimeGetSeconds(time)
        guard !second.isNaN, !second.isInfinite else { return }
        onTickHandler(Int(second))
    }
    
    private func addPeriodicTimeObserver(_ onTickHandler: @escaping IntHandler) {
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: time, queue: .main) { [weak self] time in
            self?.onTick(time, onTickHandler)
        }
    }

    private func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
}
