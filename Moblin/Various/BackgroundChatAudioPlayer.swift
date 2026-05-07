import AVFoundation

class BackgroundChatAudioPlayer {
    private var player: AVAudioPlayer?

    /// Start a silent loopback audio player with `.playback` category so iOS
    /// keeps the app alive in the background long enough to receive chat messages.
    ///
    /// Must be called on `processorControlQueue` after `teardownAudioSession()` has
    /// completed, so there is no conflicting `playAndRecord` AVAudioSession still
    /// active when the category is switched.
    func start() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, options: .mixWithOthers)
            try session.setActive(true)
        } catch {
            logger.info("BackgroundChatAudioPlayer: Failed to configure audio session: \(error)")
            return
        }
        guard let url = Bundle.main.url(forResource: "Alerts.bundle/Silence", withExtension: "mp3") else {
            logger.info("BackgroundChatAudioPlayer: Alerts.bundle/Silence.mp3 not found in bundle")
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
            player?.volume = 0
            player?.play()
        } catch {
            logger.info("BackgroundChatAudioPlayer: Failed to start silent audio player: \(error)")
        }
    }

    func stop() {
        player?.stop()
        player = nil
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            logger.info("BackgroundChatAudioPlayer: Failed to deactivate audio session: \(error)")
        }
    }
}
