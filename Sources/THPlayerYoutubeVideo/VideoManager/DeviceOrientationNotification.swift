import UIKit

@objc protocol DeviceOrientationNotification {
    @objc func didChangedOrientation()
}

extension DeviceOrientationNotification {
    func registerDeviceOrientationNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(didChangedOrientation), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    func removeDeviceOrientationNotification() {
        NotificationCenter.default.removeObserver(self)
    }
}
