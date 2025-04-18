import Foundation
import AVFoundation

public enum AudioError: Error {
  case recordPermissionDenied
  case recordingFailed
  case playbackFailed
  case fileNotFound
}

public final class AudioManager: NSObject, ObservableObject {
  // MARK: - Published Properties
  @Published public private(set) var isRecording = false
  @Published public private(set) var isPlaying = false
  @Published public private(set) var currentTime: TimeInterval = 0
  @Published public private(set) var duration: TimeInterval = 0
  
  // MARK: - Private Properties
  private var audioRecorder: AVAudioRecorder?
  private var audioPlayer: AVAudioPlayer?
  private var timer: Timer?
  
  // MARK: - Initialization
  public override init() {
    super.init()
    setupAudioSession()
  }
  
  // MARK: - Public Methods
  public func requestPermission() async -> Bool {
    return await withCheckedContinuation { continuation in
      AVAudioSession.sharedInstance().requestRecordPermission { granted in
        continuation.resume(returning: granted)
      }
    }
  }
  
  public func startRecording(fileName: String) async throws {
    guard await requestPermission() else {
      throw AudioError.recordPermissionDenied
    }
    
    let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
    let settings: [String: Any] = [
      AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
      AVSampleRateKey: 44100.0,
      AVNumberOfChannelsKey: 2,
      AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]
    
    do {
      audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
      audioRecorder?.delegate = self
      audioRecorder?.record()
      isRecording = true
      startTimer()
    } catch {
      throw AudioError.recordingFailed
    }
  }
  
  public func stopRecording() {
    audioRecorder?.stop()
    audioRecorder = nil
    isRecording = false
    stopTimer()
  }
  
  public func startPlayback(fileURL: URL) throws {
    do {
      audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
      audioPlayer?.delegate = self
      audioPlayer?.play()
      isPlaying = true
      duration = audioPlayer?.duration ?? 0
      startTimer()
    } catch {
      throw AudioError.playbackFailed
    }
  }
  
  public func pausePlayback() {
    audioPlayer?.pause()
    isPlaying = false
    stopTimer()
  }
  
  public func resumePlayback() {
    audioPlayer?.play()
    isPlaying = true
    startTimer()
  }
  
  public func stopPlayback() {
    audioPlayer?.stop()
    audioPlayer = nil
    isPlaying = false
    currentTime = 0
    stopTimer()
  }
  
  public func seek(to time: TimeInterval) {
    audioPlayer?.currentTime = time
    currentTime = time
  }
  
  // MARK: - Private Methods
  private func setupAudioSession() {
    do {
      try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default)
      try AVAudioSession.sharedInstance().setActive(true)
    } catch {
      print("Failed to set up audio session: \(error)")
    }
  }
  
  private func startTimer() {
    timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
      guard let self = self else { return }
      if self.isRecording {
        self.currentTime = self.audioRecorder?.currentTime ?? 0
      } else if self.isPlaying {
        self.currentTime = self.audioPlayer?.currentTime ?? 0
      }
    }
  }
  
  private func stopTimer() {
    timer?.invalidate()
    timer = nil
  }
  
  private func getDocumentsDirectory() -> URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
  }
}

// MARK: - AVAudioRecorderDelegate
extension AudioManager: AVAudioRecorderDelegate {
  public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
    isRecording = false
    stopTimer()
  }
  
  public func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
    print("Recording error: \(String(describing: error))")
    isRecording = false
    stopTimer()
  }
}

// MARK: - AVAudioPlayerDelegate
extension AudioManager: AVAudioPlayerDelegate {
  public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    isPlaying = false
    currentTime = 0
    stopTimer()
  }
  
  public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
    print("Playback error: \(String(describing: error))")
    isPlaying = false
    stopTimer()
  }
} 