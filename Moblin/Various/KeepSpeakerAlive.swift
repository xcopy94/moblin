import AVFoundation

class KeepChatAlivePlayer {
    static let shared = KeepChatAlivePlayer()
    private var player: AVAudioPlayer?

    func start() {
        guard player == nil else {
            return
        }
        guard let soundUrl = Bundle.main.url(forResource: "Alerts.bundle/Silence", withExtension: "mp3")
        else {
            logger.info("keep-chat-alive: Failed to find Silence.mp3")
            return
        }
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            logger.info("keep-chat-alive: Failed to setup audio session: \(error)")
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: soundUrl)
            player?.numberOfLoops = -1
            player?.play()
        } catch {
            logger.info("keep-chat-alive: Failed to play silence: \(error)")
        }
    }

    func stop() {
        player?.stop()
        player = nil
    }
}

class KeepSpeakerAlivePlayer {
    static let shared = KeepSpeakerAlivePlayer()
    private var keepSpeakerAlivePlayer: AudioPlayer?
    private var latestPlayTime: Atomic<ContinuousClock.Instant> = .init(.now)

    func audioPlayed() {
        latestPlayTime.mutate { $0 = .now }
    }

    func playIfNeeded(now: ContinuousClock.Instant) {
        guard latestPlayTime.value.duration(to: now) > .seconds(5 * 60) else {
            return
        }
        guard let soundUrl = Bundle.main.url(forResource: "Alerts.bundle/Silence", withExtension: "mp3")
        else {
            return
        }
        keepSpeakerAlivePlayer = try? AudioPlayer(contentsOf: soundUrl)
        keepSpeakerAlivePlayer?.play()
    }
}

class AudioPlayer {
    private let player: AVAudioPlayer

    init(data: Data) throws {
        player = try AVAudioPlayer(data: data)
    }

    init(contentsOf: URL) throws {
        player = try AVAudioPlayer(contentsOf: contentsOf)
    }

    func setDelegate(delegate: AVAudioPlayerDelegate) {
        player.delegate = delegate
    }

    func play() {
        KeepSpeakerAlivePlayer.shared.audioPlayed()
        player.play()
    }

    func stop() {
        player.stop()
    }
}
