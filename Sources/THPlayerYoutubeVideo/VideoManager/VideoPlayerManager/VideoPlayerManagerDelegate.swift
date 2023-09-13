import Foundation

protocol VideoPlayerManagerDelegate {
    func currentTime(second: Int, duration: Int)
    func currentPlayerState(isPlaying: Bool)
}
