import Foundation
import AVFoundation

@MainActor
class RecorderViewModel: ObservableObject {
  private let repository: AudioRecorderRepository
  private var audioPlayer: AVAudioPlayer?
  private var timer: Timer?
  
  @Published var isRecording = false
  @Published var isPlaying = false
  @Published var recordingTime: TimeInterval = 0
  @Published var currentRecording: AudioRecording?
  
  init(repository: AudioRecorderRepository) async {
    self.repository = repository
  }
  
  func startRecording() {
    do {
      try repository.startRecording()
      isRecording = true
      recordingTime = 0
      
      timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
        Task { @MainActor [weak self] in
          self?.recordingTime += 0.1
        }
      }
    } catch {
      print("錄音失敗: \(error.localizedDescription)")
    }
  }
  
  func stopRecording() {
    currentRecording = repository.stopRecording()
    isRecording = false
    timer?.invalidate()
  }
  
  func startPlayback() {
    guard let recording = currentRecording else { return }
    
    do {
      audioPlayer = try AVAudioPlayer(contentsOf: recording.url)
      audioPlayer?.delegate = AVPlayerObserver.shared
      AVPlayerObserver.shared.onEnd = { [weak self] in
        Task { @MainActor [weak self] in
          self?.isPlaying = false
        }
      }
      audioPlayer?.play()
      isPlaying = true
    } catch {
      print("播放失敗: \(error.localizedDescription)")
    }
  }
  
  func stopPlayback() {
    audioPlayer?.stop()
    isPlaying = false
  }
  
  func resetRecording() {
    if isPlaying {
      stopPlayback()
    }
    
    if let recording = currentRecording {
      try? repository.deleteRecording(recording)
    }
    
    currentRecording = nil
    recordingTime = 0
  }
  
  func timeString(time: TimeInterval) -> String {
    let minutes = Int(time) / 60
    let seconds = Int(time) % 60
    let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 10)
    return String(format: "%02d:%02d.%01d", minutes, seconds, milliseconds)
  }
} 