import AVKit
import Foundation
import XCDYouTubeKit

class VideoPlayerManager: NSObject {
    private var timeObserver: Any?
    private var player: AVPlayer = .init()
    private(set) var controller = AVPlayerViewController()
    private var delegate: VideoPlayerManagerDelegate?

    private(set) var duration: Double!
    private(set) var isPlaying: Bool = false {
        didSet {
            delegate?.currentPlayerState(isPlaying: isPlaying)
        }
    }

    init(delegate: VideoPlayerManagerDelegate?) {
        super.init()
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [.allowAirPlay])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
        registerNotification()
        self.delegate = delegate
        controller.showsPlaybackControls = false
    }

    deinit {
        removeNotification()
        guard let timeObserver else { return }
        player.removeTimeObserver(timeObserver)
    }
}

// MARK: Function

extension VideoPlayerManager {
    func play(url: URL) {
        player = AVPlayer(url: url)
        controller.player = player
        isPlaying = true
        player.play()
    }

    func play(with videoYTID: String, loadingComplete: @escaping (Result<Bool, Error>) -> Void) {
        XCDYouTubeClient.default().getVideoWithIdentifier(videoYTID) { [weak self] (video: XCDYouTubeVideo?, error: Error?) in
            if let video {
                self?.handleGetVideoSuccess(video: video, loadingComplete: loadingComplete)
            } else {
                guard let error else { return }
                loadingComplete(.failure(error))
            }
        }
    }

    private func handleGetVideoSuccess(video: XCDYouTubeVideo, loadingComplete: @escaping (Result<Bool, Error>) -> Void) {
        if let streamURL = video.streamURLs[XCDYouTubeVideoQuality.HD720.rawValue] ??
            video.streamURLs[XCDYouTubeVideoQuality.medium360.rawValue] ??
            video.streamURLs[XCDYouTubeVideoQuality.small240.rawValue]
        {
            play(url: streamURL)
            loadingComplete(.success(true))
        } else if let streamURL = video.streamURLs["HTTPLiveStreaming"] {
            // TODO: - This not display with this url
            play(url: streamURL)
            loadingComplete(.success(false))
        }
    }

    func changePlayState() {
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
    }

    func seekTo(second: Int) {
        let currentTime = player.currentTime()
        let secondTime = CMTime(seconds: Double(second), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.seek(to: currentTime + secondTime,
                    toleranceBefore: .zero,
                    toleranceAfter: .zero)
    }
}

// MARK: VideoPlayerNotification

extension VideoPlayerManager: VideoPlayerNotification {
    func didEnterBackground() {
        controller.player = nil
    }

    func willEnterForeground() {
        controller.player = player
    }

    func playerItemReadyToPlay() {
        timeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(value: 1, timescale: CMTimeScale(NSEC_PER_SEC)),
            queue: .main)
        { [weak self] currentTime in
            guard self?.player.currentItem?.status == .readyToPlay,
                  let durationDouble = self?.player.currentItem?.duration.seconds else { return }
            let duration = Int(durationDouble)
            let second = Int(CMTimeGetSeconds(currentTime))
            self?.delegate?.currentTime(second: second, duration: duration)
        }
    }

    func didPlayEndToTime() {
        // TODO: - Play Next Video
        print("Play next video")
    }
}
