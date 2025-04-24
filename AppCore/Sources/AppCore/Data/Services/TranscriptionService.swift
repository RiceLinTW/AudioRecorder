import UIKit
import DataStore
import NetworkService

@MainActor
final class TranscriptionService: @unchecked Sendable {
  private let recordingStore: RecordingStoreActor
  private let authService = AuthService.shared
  private let ollamaAPI = OllamaAPI()
  private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
  
  init(recordingStore: RecordingStoreActor) {
    self.recordingStore = recordingStore
  }
  
  func transcribe(recording: RecordingModel) async throws {
    guard let hephAPI = authService.getAPI() else {
      throw NSError(domain: "TranscriptionService", code: -1, userInfo: [
        NSLocalizedDescriptionKey: "請先登入 Heph 服務"
      ])
    }
    
    // 開始背景任務
    backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
      guard let self else { return }
      UIApplication.shared.endBackgroundTask(self.backgroundTask)
      self.backgroundTask = .invalid
    }
    
    defer {
      if backgroundTask != .invalid {
        Task { @MainActor in
          UIApplication.shared.endBackgroundTask(backgroundTask)
          backgroundTask = .invalid
        }
      }
    }
    
    print("🎯 開始轉錄: \(recording.title)")
    
    // 上傳音檔
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let url = documentsPath.appendingPathComponent(recording.filename)
    let task = try await hephAPI.uploadAudio(fileURL: url)
    
    // 等待轉錄完成
    var status = try await hephAPI.checkStatus(taskID: task.data.task_id)
    while status.data.status != "Completed" {
      recording.progress = status.data.progress
      try await recordingStore.update(recording)
      
      try await Task.sleep(for: .seconds(2))
      status = try await hephAPI.checkStatus(taskID: task.data.task_id)
      print("📊 轉錄進度: \(status.data.progress)")
    }
    
    // 取得結果
    let result = try await hephAPI.getResult(taskID: task.data.task_id)
    
    // 更新資料庫
    recording.transcript = result.text
    recording.progress = nil
    try await recordingStore.update(recording)
    
    print("✅ 轉錄完成")
  }
  
  func summarize(recording: RecordingModel, transcript: String) async throws {
    // 開始背景任務
    backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
      guard let self else { return }
      UIApplication.shared.endBackgroundTask(self.backgroundTask)
      self.backgroundTask = .invalid
    }
    
    defer {
      if backgroundTask != .invalid {
        Task { @MainActor in
          UIApplication.shared.endBackgroundTask(backgroundTask)
          backgroundTask = .invalid
        }
      }
    }
    
    print("🎯 開始摘要: \(recording.title)")
    
    // 更新狀態
    recording.isSummarizing = true
    try await recordingStore.update(recording)
    
    // 生成摘要
    let summary = try await ollamaAPI.generateSummary(text: transcript)
    
    // 更新資料庫
    recording.summary = summary
    recording.isSummarizing = false
    try await recordingStore.update(recording)
    
    print("✅ 摘要完成")
  }
  
  func updateSummary(recording: RecordingModel, summary: String) async throws {
    recording.summary = summary
    try await recordingStore.update(recording)
  }
} 
