import SDWebImage
import UIKit

public class VideoPlayerViewController: UIViewController {
    @IBOutlet private var durationLabel: UILabel!
    @IBOutlet private var progress: UIProgressView!
    @IBOutlet private var thumnailImageView: UIImageView!
    @IBOutlet private var indicator: UIActivityIndicatorView!
    @IBOutlet private var containerPlayStateStackView: UIStackView!
    @IBOutlet private var containerSettingStackView: UIStackView!
    @IBOutlet private var playButton: UIButton!
    @IBOutlet private var expandButton: UIButton!
    @IBOutlet private var containerActionView: UIView!

    private var videoID: String!
    private var thumnailURL: String!
    private var debouncer: Debouncer?
    private lazy var videoPlayerManager = VideoPlayerManager.shared

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerDeviceOrientationNotification()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        configView()
        videoPlayerManager.setDelegate(delegate: self)
    }

    private func configView() {
        thumnailImageView.sd_setImage(with: URL(string: thumnailURL))
        containerActionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapInsideContainerActionView)))
        debouncer = .init(delay: 3, callback: { [weak self] in
            self?.displayActionView(isHidden: true)
        })
        displayIndicator(isHidden: false)
        videoPlayerManager.play(with: videoID) { [weak self] result in
            DispatchQueue.main.async {
                self?.displayIndicator(isHidden: true)
                switch result {
                case .success(let success):
                    if success { self?.addVideoPlayer() }
                case .failure(let failure):
                    print(Self.self, #function, failure)
                }
            }
        }
    }

    private func addVideoPlayer() {
        videoPlayerManager.controller.view.frame = view.bounds
        view.insertSubview(videoPlayerManager.controller.view, at: 1)
    }

    private func displayIndicator(isHidden: Bool) {
        indicator.isHidden = isHidden
        containerActionView.isHidden = !isHidden
    }

    private func displayActionView(isHidden: Bool) {
        containerSettingStackView.isHidden = isHidden
        containerPlayStateStackView.isHidden = isHidden
    }

    @objc private func tapInsideContainerActionView() {
        displayActionView(isHidden: false)
        debouncer?.call()
    }

    @IBAction private func touchUpInsideGoForwardButton(_ sender: Any) {
        videoPlayerManager.seekTo(second: 10)
        debouncer?.call()
    }

    @IBAction private func touchUpInsidePlayButton(_ sender: Any) {
        videoPlayerManager.changePlayState()
        debouncer?.call()
    }

    @IBAction private func touchUpInsideGoBackwardButton(_ sender: Any) {
        videoPlayerManager.seekTo(second: -10)
        debouncer?.call()
    }

    @IBAction private func touchUpInsideExpandButton(_ sender: Any) {
        changeOrientation()
        debouncer?.call()
    }

    private func changeOrientation() {
        DispatchQueue.main.async {
            if #available(iOS 16, *) {
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                self.setNeedsUpdateOfSupportedInterfaceOrientations()
                windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: windowScene?.interfaceOrientation == .portrait ? .landscapeRight : .portrait)) { error in
                    fatalError(error.localizedDescription)
                }
            } else {
                UIDevice.current.setValue(
                    UIDevice.current.orientation == .portrait ? UIInterfaceOrientation.landscapeRight.rawValue : UIInterfaceOrientation.portrait.rawValue,
                    forKey: "orientation"
                )
            }
        }
    }

    deinit {
        removeDeviceOrientationNotification()
    }
}

// MARK: Init

public extension VideoPlayerViewController {
    static func initial(videoID: String, thumnailURL: String) -> VideoPlayerViewController {
        print(Self.self, #function, "Init from ", Bundle.module.bundleIdentifier ?? "NSBundle")
        let storyboard = UIStoryboard(name: "\(Self.self)", bundle: Bundle.module)
        let viewController = storyboard.instantiateViewController(withIdentifier: "\(Self.self)") as! VideoPlayerViewController
        viewController.videoID = videoID
        viewController.thumnailURL = thumnailURL
        return viewController
    }
}

// MARK: VideoPlayerManagerDelegate

extension VideoPlayerViewController: VideoPlayerManagerDelegate {
    func currentTime(second: Int, duration: Int) {
        durationLabel.text = "\(second.convertSecondToTimeString()) / \(duration.convertSecondToTimeString())"
        progress.progress = Float(second) / Float(duration)
    }

    func currentPlayerState(isPlaying: Bool) {
        playButton.isSelected = isPlaying
    }
}

// MARK:

extension VideoPlayerViewController: DeviceOrientationNotification {
    func didChangedOrientation() {
        expandButton.isSelected = UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight
    }
}
