import Foundation
import AVFoundation

protocol AVPlayerObserverProtocol {
    var statusHandler: StatusHandler? { get }
    var playerItem: AVPlayerItem? { get }
    var timeObserverToken: Any? { get }
    func addObserver(to playerItem: AVPlayerItem)
    func addPeriodicTimeObserver(to player: AVPlayer, _ onTickHandler: @escaping DurationHandler)
    func removePeriodicTimeObserver(from player: AVPlayer)
    func dispose(_ player: AVPlayer)
}

class AVPlayerObserver: NSObject, AVPlayerObserverProtocol {
    
    var statusHandler: StatusHandler?
    var playerItem: AVPlayerItem?
    var timeObserverToken: Any?
    var playerItemContext = 0
    
    public init(with handler: @escaping StatusHandler) {
        self.statusHandler = handler
    }
    
    public override init() {}
    
    public func addObserver(to playerItem: AVPlayerItem) {
        self.playerItem = playerItem
        playerItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.new], context: &playerItemContext)
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            if let statusNumber = (change?[.newKey] as? NSNumber)?.intValue, let avStatus = AVPlayerItem.Status(rawValue: statusNumber) {
                status = avStatus
            } else {
                status = .unknown
            }
            statusHandler?(status)
        }
    }
    
    func addPeriodicTimeObserver(to player: AVPlayer, _ onTickHandler: @escaping DurationHandler) {
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: time, queue: .main) { time in
            let second = CMTimeGetSeconds(time)
            guard !second.isNaN, !second.isInfinite else { return }
            onTickHandler(second, player.duration)
        }
    }
    
    func removePeriodicTimeObserver(from player: AVPlayer) {
        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    func dispose(_ player: AVPlayer) {
        playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
        removePeriodicTimeObserver(from: player)
        
    }
    
}
