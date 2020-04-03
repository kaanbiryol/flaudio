
import Foundation
import AVFoundation

enum Channel {
    static let prepare = "prepare"
    static let play = "play"
}

protocol Playable {
    var player: AVPlayer { get }
    func prepare(_ urlString: String)
    func play()
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
        print("KAAN", player)
        player.play()
    }
    
}
