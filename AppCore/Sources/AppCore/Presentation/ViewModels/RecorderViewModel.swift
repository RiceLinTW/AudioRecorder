import Foundation
import UIKit
import AVFoundation
import SwiftData
import DataStore
import AudioService

@MainActor
class RecorderViewModel: ObservableObject {
  private let repository: AudioRecorderRepository
  private let recordingStore: RecordingStoreActor
  private let transcriptionService: TranscriptionService
  private let notificationService = NotificationService.shared
  private var audioPlayer: AVAudioPlayer?
  private var timer: Timer?
  private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
  
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
      // 如果有正在轉錄的錄音，設定定時更新
      if recordings.contains(where: { $0.progress != nil }) {
        Task {
          try await Task.sleep(for: .seconds(1))
          await loadRecordings()
        }
      }
    } catch {
      self.error = RecorderError.recording(error.localizedDescription)
    }
  }
  
  func startRecording() {
    Task {
      do {
        // 開始背景任務
        backgroundTask = UIApplication.shared.beginBackgroundTask {
          UIApplication.shared.endBackgroundTask(self.backgroundTask)
          self.backgroundTask = .invalid
        }
        
        try await repository.startRecording()
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
  }
  
  func stopRecording() {
    if let recording = repository.stopRecording() {
      currentRecording = recording
      Task {
        do {
          _ = try await recordingStore.save(recording)
          await loadRecordings()
          // 重置當前錄音
          currentRecording = nil
          recordingTime = 0
        } catch {
          self.error = RecorderError.recording(error.localizedDescription)
        }
      }
    }
    isRecording = false
    timer?.invalidate()
    timer = nil
    
    // 結束背景任務
    if backgroundTask != .invalid {
      UIApplication.shared.endBackgroundTask(backgroundTask)
      backgroundTask = .invalid
    }
  }
  
  func startTranscription(_ recording: RecordingModel) async throws {
    isTranscribing = true
    defer { isTranscribing = false }
    
    // 立即開始更新錄音列表
    Task {
      await loadRecordings()
    }
    
    try await transcriptionService.transcribe(recording: recording)
    await loadRecordings()
    notificationService.scheduleTranscriptionNotification(title: recording.title)
  }
  
  func startSummary(_ recording: RecordingModel) async throws {
    guard let transcript = recording.transcript else {
      throw RecorderError.transcription("請先進行轉錄")
    }
    
    try await transcriptionService.summarize(recording: recording, transcript: transcript)
    await loadRecordings()
    notificationService.scheduleSummaryNotification(title: recording.title)
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
  
  func updateSummary(_ recording: RecordingModel, summary: String) async throws {
    try await transcriptionService.updateSummary(recording: recording, summary: summary)
    await loadRecordings()
  }
  
  func playRecording(_ recording: RecordingModel) async throws {
    if isPlaying {
      stopPlayback()
    }
    
    do {
      let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
      let url = documentsPath.appendingPathComponent(recording.filename)
      print("Playing audio from: \(url.path)")
      
      audioPlayer = try AVAudioPlayer(contentsOf: url)
      audioPlayer?.delegate = AVPlayerObserver.shared
      AVPlayerObserver.shared.onEnd = { [weak self] in
        Task { @MainActor [weak self] in
          self?.isPlaying = false
        }
      }
      audioPlayer?.play()
      isPlaying = true
    } catch {
      print("播放錯誤: \(error)")
      throw RecorderError.playback(error.localizedDescription)
    }
  }
} 
