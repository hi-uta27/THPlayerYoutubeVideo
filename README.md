# THPlayer in developing - My Learning
This my first package, this's use for play video with AVPlayer

### How to use it?
- Import from Package dependency:
```swift
.dependencies: [
    .package(url: "https://github.com/hi-uta27/THPlayerYoutubeVideo", from: "main"),
]
```

- To embed **VideoPlayerViewController** into your viewController:
```swift
class YourViewController: UIViewController {
    @IBOutlet private var videoContainer: UIView!

    private lazy var vc = VideoPlayerViewController.initial(
        videoID: "KSe4k0WrpjY",
        thumnailURL: "https://phunugioi.com/wp-content/uploads/2020/11/hinh-anh-meo-de-thuong-dep-nhat.jpg")

    override func viewDidLoad() {
        super.viewDidLoad()

        vc.view.frame = videoContainer.bounds
        vc.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        videoContainer.addSubview(vc.view)
    }
}
```

### Library using:
- [XCDYouTubeKit-cbg-dev-k](https://github.com/cbg-dev-k/XCDYouTubeKit)
- [SDWebImage](https://github.com/SDWebImage/SDWebImage.git)
