import AVFoundation

class BackgroundChatAudioPlayer {
    private var player: AVAudioPlayer?

    func start() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, options: .mixWithOthers)
            try session.setActive(true)
        } catch {
            logger.warning("BackgroundChatAudioPlayer: Failed to configure audio session: \(error)")
            return
        }
        guard let url = Bundle.main.url(forResource: "Alerts.bundle/Silence", withExtension: "mp3") else {
            logger.warning("BackgroundChatAudioPlayer: Silence.mp3 not found in bundle")
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
            player?.play()
        } catch {
            logger.warning("BackgroundChatAudioPlayer: Failed to create audio player: \(error)")
        }
    }

    func stop() {
        player?.stop()
        player = nil
    }
}
