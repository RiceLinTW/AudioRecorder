import Foundation
import AVFoundation
import SwiftData

@MainActor
class RecorderViewModel: ObservableObject {
  private let repository: AudioRecorderRepository
  private let recordingStore: RecordingStoreActor
  private var audioPlayer: AVAudioPlayer?
  private var timer: Timer?
  
  @Published var isRecording = false
  @Published var isPlaying = false
  @Published var recordingTime: TimeInterval = 0
  @Published var currentRecording: AudioRecording?
  @Published var recordings: [RecordingModel] = []
  @Published var error: Error?
  
  init(repository: AudioRecorderRepository, recordingStore: RecordingStoreActor) async {
    self.repository = repository
    self.recordingStore = recordingStore
    await loadRecordings()
  }
  
  private func loadRecordings() async {
    do {
      recordings = try await recordingStore.fetchAll()
    } catch {
      self.error = error
    }
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
      self.error = error
    }
  }
  
  func stopRecording() {
    if let recording = repository.stopRecording() {
      currentRecording = recording
      Task {
        do {
          try await recordingStore.save(recording)
          await loadRecordings()
        } catch {
          self.error = error
        }
      }
    }
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
      self.error = error
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
      Task {
        do {
          if let model = try await recordingStore.find(by: recording.id) {
            try await recordingStore.delete(model)
            await loadRecordings()
          }
        } catch {
          self.error = error
        }
      }
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