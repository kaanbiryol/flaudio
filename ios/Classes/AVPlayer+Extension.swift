import Foundation
import AVFoundation

extension AVPlayer {
    
    var duration: Int {
        guard let currentTime = currentItem?.duration, !currentTime.isIndefinite else { return 0 }
        return Int(CMTimeGetSeconds(currentTime))
    }
    
    convenience init(customURL: URL, observer: AVPlayerObserverProtocol) {
        let asset = AVAsset(url: customURL)
        let playerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: ["playable", "hasProtectedContent"])
        observer.addObserver(to: playerItem)
        self.init(playerItem: playerItem)
    }
    
}