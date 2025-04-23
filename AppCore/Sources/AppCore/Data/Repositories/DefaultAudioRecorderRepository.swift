import Foundation
import AVFoundation

#if os(iOS)
class DefaultAudioRecorderRepository: AudioRecorderRepository {
  private var audioRecorder: AVAudioRecorder?
  private var currentRecordingURL: URL?
  
  init() {
    setupAudioSession()
  }
  
  private func setupAudioSession() {
    let audioSession = AVAudioSession.sharedInstance()
    do {
      try audioSession.setCategory(
        .playAndRecord,
        mode: .default,
        options: [.allowBluetooth, .defaultToSpeaker, .mixWithOthers]
      )
      try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    } catch {
      print("設置音頻會話失敗: \(error.localizedDescription)")
    }
  }
  
  func startRecording() throws {
    let audioSession = AVAudioSession.sharedInstance()
    try audioSession.setActive(true)
    
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let audioFilename = documentsPath.appendingPathComponent("\(UUID().uuidString).wav")
    currentRecordingURL = audioFilename
    
    let settings: [String: Any] = [
      AVFormatIDKey: Int(kAudioFormatLinearPCM),
      AVSampleRateKey: 44100.0,
      AVNumberOfChannelsKey: 2,
      AVLinearPCMBitDepthKey: 16,
      AVLinearPCMIsFloatKey: false,
      AVLinearPCMIsBigEndianKey: false,
      AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]
    
    audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
    audioRecorder?.record()
  }
  
  func stopRecording() -> AudioRecording? {
    guard let url = currentRecordingURL else { return nil }
    audioRecorder?.stop()
    let duration = audioRecorder?.currentTime ?? 0
    return AudioRecording(url: url, duration: duration)
  }
  
  func deleteRecording(_ recording: AudioRecording) throws {
    try FileManager.default.removeItem(at: recording.url)
  }
  
  func getRecordingURL() -> URL? {
    return currentRecordingURL
  }
}
#else
class DefaultAudioRecorderRepository: AudioRecorderRepository {
  func startRecording() throws {
    throw NSError(domain: "AudioRecorder", code: -1, userInfo: [NSLocalizedDescriptionKey: "Recording is not supported on this platform"])
  }
  
  func stopRecording() -> AudioRecording? {
    return nil
  }
  
  func deleteRecording(_ recording: AudioRecording) throws {
    throw NSError(domain: "AudioRecorder", code: -1, userInfo: [NSLocalizedDescriptionKey: "Recording is not supported on this platform"])
  }
  
  func getRecordingURL() -> URL? {
    return nil
  }
}
#endif 