import UIKit

@objc protocol VideoPlayerNotification {
    @objc func didEnterBackground()
    @objc func willEnterForeground()
    @objc func playerItemReadyToPlay()
    @objc func didPlayEndToTime()
}

extension VideoPlayerNotification {
    func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemReadyToPlay), name: .AVPlayerItemNewAccessLogEntry, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didPlayEndToTime), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }

    func removeNotification() {
        NotificationCenter.default.removeObserver(self)
    }
}
