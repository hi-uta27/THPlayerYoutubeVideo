import Foundation

extension Int {
    func convertSecondToTimeString() -> String {
        let hour = self / 3600
        let minute = (self % 3600) / 60
        let second = (self % 3600) % 60
        return hour == 0 ? String(format: "%02d:%02d", minute, second) : String(format: "%02d:%02d:%02d", hour, minute, second)
    }
}
