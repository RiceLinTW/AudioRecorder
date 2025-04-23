import UIKit

class TranscriptionService {
  private let recordingStore: RecordingStoreActor
  private let hephAPI = HephAPI()
  private let ollamaAPI = OllamaAPI()
  private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
  
  init(recordingStore: RecordingStoreActor) {
    self.recordingStore = recordingStore
  }
  
  func transcribe(recording: RecordingModel) async throws {
    // 開始背景任務
    backgroundTask = UIApplication.shared.beginBackgroundTask {
      UIApplication.shared.endBackgroundTask(self.backgroundTask)
      self.backgroundTask = .invalid
    }
    
    defer {
      if backgroundTask != .invalid {
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
      }
    }
    
    print("🎯 開始轉錄: \(recording.title)")
    
    // 上傳音檔
    let task = try await hephAPI.uploadAudio(fileURL: URL(filePath: recording.filePath))
    
    // 等待轉錄完成
    var status = try await hephAPI.checkStatus(taskID: task.data.task_id)
    while status.data.status != "Completed" {
      try await Task.sleep(for: .seconds(5))
      status = try await hephAPI.checkStatus(taskID: task.data.task_id)
      print("📊 轉錄進度: \(status.data.progress)")
    }
    
    // 取得結果
    let result = try await hephAPI.getResult(taskID: task.data.task_id)
    
    // 更新資料庫
    recording.transcript = result.text
    try await recordingStore.update(recording)
    
    print("✅ 轉錄完成")
  }
  
  func summarize(recording: RecordingModel, transcript: String) async throws {
    // 開始背景任務
    backgroundTask = UIApplication.shared.beginBackgroundTask {
      UIApplication.shared.endBackgroundTask(self.backgroundTask)
      self.backgroundTask = .invalid
    }
    
    defer {
      if backgroundTask != .invalid {
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
      }
    }
    
    print("🎯 開始摘要: \(recording.title)")
    
    // 生成摘要
    let summary = try await ollamaAPI.generateSummary(text: transcript)
    
    // 更新資料庫
    recording.summary = summary
    try await recordingStore.update(recording)
    
    print("✅ 摘要完成")
  }
} 
