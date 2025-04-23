import Foundation

actor TranscriptionService {
  private let hephAPI: HephAPI
  private let ollamaAPI: OllamaAPI
  private let recordingStore: RecordingStoreActor
  
  init(hephAPI: HephAPI = HephAPI(),
       ollamaAPI: OllamaAPI = OllamaAPI(),
       recordingStore: RecordingStoreActor) {
    self.hephAPI = hephAPI
    self.ollamaAPI = ollamaAPI
    self.recordingStore = recordingStore
  }
  
  func transcribe(recording: RecordingModel) async throws {
    print("🎯 開始轉錄流程: \(recording.title)")
    print("📂 音檔路徑: \(recording.filePath)")
    
    // 上傳音檔
    let task = try await hephAPI.uploadAudio(fileURL: URL(filePath: recording.filePath))
    
    // 等待轉錄完成
    print("⏳ 等待轉錄完成...")
    var status = try await hephAPI.checkStatus(taskID: task.data.task_id)
    while status.data.status != "Completed" {
      try await Task.sleep(for: .seconds(2))
      status = try await hephAPI.checkStatus(taskID: task.data.task_id)
    }
    
    // 取得轉錄結果
    print("🔄 取得轉錄結果...")
    let result = try await hephAPI.getResult(taskID: task.data.task_id)
    
    // 更新錄音資訊
    print("📝 更新錄音資訊...")
    let updatedRecording = recording
    updatedRecording.transcript = result.text
    
    // 生成摘要
    print("🤖 生成 AI 摘要...")
    let summary = try await ollamaAPI.generateSummary(text: result.text)
    updatedRecording.summary = summary
    
    // 儲存更新
    print("💾 儲存更新...")
    try await recordingStore.update(updatedRecording)
    print("✅ 轉錄流程完成!")
  }
}
