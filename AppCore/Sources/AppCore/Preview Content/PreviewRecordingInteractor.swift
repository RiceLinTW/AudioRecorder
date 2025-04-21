import Foundation

class PreviewRecordingInteractor: RecordingUseCases {
  private var recordings: [Recording] = [
    Recording(
      fileName: "會議記錄.m4a",
      createdAt: Date().addingTimeInterval(-3600),
      duration: 1825
    ),
    Recording(
      fileName: "課程筆記.m4a",
      createdAt: Date().addingTimeInterval(-7200),
      duration: 2430
    ),
    Recording(
      fileName: "備忘錄.m4a",
      createdAt: Date().addingTimeInterval(-86400),
      duration: 145
    )
  ]
  
  func startRecording(fileName: String) async throws {}
  
  func stopRecording() async throws -> Recording {
    Recording(fileName: "新錄音.m4a", duration: 30)
  }
  
  func playRecording(_ recording: Recording) async throws {}
  
  func pauseRecording() async {}
  
  func deleteRecording(_ recording: Recording) async throws {
    recordings.removeAll { $0.id == recording.id }
  }
  
  func getAllRecordings() async throws -> [Recording] {
    recordings
  }
  
  func getRecordingTranscript(_ recording: Recording) async throws -> String {
    "這是一段測試用的逐字稿內容..."
  }
  
  func getRecordingSummary(_ recording: Recording) async throws -> String {
    "這是一段測試用的摘要內容..."
  }
} 