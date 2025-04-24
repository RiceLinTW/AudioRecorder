import Foundation
import AVFoundation
import DataStore

#if os(iOS)
public class DefaultAudioRecorderRepository: AudioRecorderRepository {
  private var audioRecorder: AVAudioRecorder?
  private var currentRecordingURL: URL?
  
  public init() {
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
    
  public func startRecording() async throws {
    let audioSession = AVAudioSession.sharedInstance()
    
    // 檢查麥克風權限
    if #available(iOS 17.0, *) {
      let application = AVAudioApplication.shared
      switch application.recordPermission {
      case .undetermined:
        let granted = await withCheckedContinuation { continuation in
          AVAudioApplication.requestRecordPermission { granted in
            continuation.resume(returning: granted)
          }
        }
        if !granted {
          throw RecorderError.recording("未獲得麥克風權限")
        }
      case .denied:
        throw RecorderError.recording("麥克風權限已被拒絕，請在設定中開啟")
      case .granted:
        break
      @unknown default:
        throw RecorderError.recording("未知的麥克風權限狀態")
      }
    } else {
      switch audioSession.recordPermission {
      case .undetermined:
        let granted = await withCheckedContinuation { continuation in
          audioSession.requestRecordPermission { granted in
            continuation.resume(returning: granted)
          }
        }
        if !granted {
          throw RecorderError.recording("未獲得麥克風權限")
        }
      case .denied:
        throw RecorderError.recording("麥克風權限已被拒絕，請在設定中開啟")
      case .granted:
        break
      @unknown default:
        throw RecorderError.recording("未知的麥克風權限狀態")
      }
    }
    
    // 啟動音頻會話
    do {
      try audioSession.setActive(true)
    } catch {
      throw RecorderError.recording("啟動音頻會話失敗：\(error.localizedDescription)")
    }
    
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
    
    do {
      audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
      audioRecorder?.record()
    } catch {
      throw RecorderError.recording("建立錄音器失敗：\(error.localizedDescription)")
    }
  }
  
  public func stopRecording() -> AudioRecording? {
    guard let url = currentRecordingURL else { return nil }
    
    let duration = audioRecorder?.currentTime ?? 0
    audioRecorder?.stop()
    audioRecorder = nil
    currentRecordingURL = nil
    
    return AudioRecording(url: url, duration: duration)
  }
  
  public func deleteRecording(_ recording: AudioRecording) throws {
    try FileManager.default.removeItem(at: recording.url)
  }
  
  public func getRecordingURL() -> URL? {
    return currentRecordingURL
  }
}
#else
public class DefaultAudioRecorderRepository: AudioRecorderRepository {
  public init() {}
  
  public func startRecording() throws {
    throw NSError(domain: "AudioRecorder", code: -1, userInfo: [NSLocalizedDescriptionKey: "Recording is not supported on this platform"])
  }
  
  public func stopRecording() -> AudioRecording? {
    return nil
  }
  
  public func deleteRecording(_ recording: AudioRecording) throws {
    throw NSError(domain: "AudioRecorder", code: -1, userInfo: [NSLocalizedDescriptionKey: "Recording is not supported on this platform"])
  }
  
  public func getRecordingURL() -> URL? {
    return nil
  }
}
#endif 