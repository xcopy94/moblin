import AVFoundation

class BackgroundChatAudioPlayer {
    private var player: AVAudioPlayer?

    /// Start a silent loopback audio player with `.playback` category so iOS
    /// keeps the app alive in the background long enough to receive chat messages.
    ///
    /// MUST be called after `teardownAudioSession()` has completed so there is
    /// no conflicting `playAndRecord` AVCaptureSession still holding the
    /// audio session (OSStatus 561017449 / kAudioSessionIncompatibleCategory).
    func start() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(false, options: .notifyOthersOnDeactivation)
            try session.setCategory(.playback, options: .mixWithOthers)
            try session.setActive(true)
        } catch {
            logger.info("BackgroundChatAudioPlayer: Failed to configure audio session: \(error)")
            return
        }
        guard let url = Bundle.main.url(forResource: "Alerts.bundle/Silence", withExtension: "mp3") else {
            logger.info("BackgroundChatAudioPlayer: Silence.mp3 not found in bundle")
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
    }
}
