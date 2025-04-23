import Foundation
import AVFoundation
import SwiftData

@MainActor
class RecorderViewModel: ObservableObject {
  private let repository: AudioRecorderRepository
  private let recordingStore: RecordingStoreActor
  private let transcriptionService: TranscriptionService
  private var audioPlayer: AVAudioPlayer?
  private var timer: Timer?
  
  @Published var isRecording = false
  @Published var isPlaying = false
  @Published var isTranscribing = false
  @Published var recordingTime: TimeInterval = 0
  @Published var currentRecording: AudioRecording?
  @Published var recordings: [RecordingModel] = []
  @Published var error: RecorderError?
  
  init(repository: AudioRecorderRepository, recordingStore: RecordingStoreActor) {
    self.repository = repository
    self.recordingStore = recordingStore
    self.transcriptionService = TranscriptionService(recordingStore: recordingStore)
    Task {
      await loadRecordings()
    }
  }
  
  func deleteRecording(_ recording: RecordingModel) async throws {
    do {
      try await recordingStore.delete(recording)
      await loadRecordings()
    } catch {
      throw RecorderError.deletion(error.localizedDescription)
    }
  }
  
  private func loadRecordings() async {
    do {
      recordings = try await recordingStore.fetchAll()
    } catch {
      self.error = RecorderError.recording(error.localizedDescription)
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
      self.error = RecorderError.recording(error.localizedDescription)
    }
  }
  
  func stopRecording() {
    if let recording = repository.stopRecording() {
      currentRecording = recording
      Task {
        do {
          let savedRecording = try await recordingStore.save(recording)
          await loadRecordings()
          
          // 自動開始轉錄
          isTranscribing = true
          try await transcriptionService.transcribe(recording: savedRecording)
          isTranscribing = false
          await loadRecordings()
        } catch {
          self.error = RecorderError.transcription(error.localizedDescription)
          isTranscribing = false
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
      self.error = RecorderError.playback(error.localizedDescription)
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
          self.error = RecorderError.deletion(error.localizedDescription)
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
