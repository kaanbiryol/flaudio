import Foundation
import AVFoundation

enum Channel {
    static let prepare = "prepare"
    static let play = "play"
    static let playbackSpeed = "playbackSpeed"
    static let seek = "seek"
}

protocol Playable {
    var player: AVPlayer { get }
    func prepare(_ urlString: String)
    func play()
    func playbackSpeed(to rate: Float)
    func seek(by seconds: Int)
}

public class AudioManager: Playable {
    
    static var shared: AudioManager = AudioManager()
    
    private init() {}
    
    var player: AVPlayer = AVPlayer()
    
    func prepare(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        
        player = AVPlayer(url: url)
    }
    
    func play() {
        player.play()
    }
    
    func playbackSpeed(to rate: Float) {
        player.rate = rate
    }
    
    func seek(by seconds: Int) {
        let seekingForward: Bool = seconds > 0
        guard let currentItemDuration  = player.currentItem?.duration else { return }
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let soughtTime = currentTime + Float64(seconds)
        let time: CMTime = CMTimeMake(value: Int64(soughtTime * 1000 as Float64), timescale: 1000)
        player.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
    }
    
}
