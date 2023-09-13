import Foundation

public class Debouncer: NSObject {
    private var callback: () -> Void
    private var delay: Double
    private weak var timer: Timer?

    public init(delay: Double, callback: @escaping (() -> Void)) {
        self.delay = delay
        self.callback = callback
    }

    public func call() {
        timer?.invalidate()
        let nextTimer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(Debouncer.fireNow), userInfo: nil, repeats: false)
        timer = nextTimer
    }

    @objc private func fireNow() {
        callback()
    }

    deinit {
        timer?.invalidate()
    }
}
