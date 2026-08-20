import AVFAudio
import OSLog

@MainActor
enum VideoPlaybackAudioSession {
    private static let logger = Logger(
        subsystem: "com.vitaliibadion.burnroll",
        category: "VideoPlayback"
    )

    static func activate() {
        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(.playback, mode: .moviePlayback)
            try audioSession.setActive(true)
        } catch {
            logger.error("Unable to activate video playback audio: \(error.localizedDescription, privacy: .public)")
        }
    }

    static func deactivate() {
        do {
            try AVAudioSession.sharedInstance().setActive(
                false,
                options: .notifyOthersOnDeactivation
            )
        } catch {
            logger.error("Unable to deactivate video playback audio: \(error.localizedDescription, privacy: .public)")
        }
    }
}
