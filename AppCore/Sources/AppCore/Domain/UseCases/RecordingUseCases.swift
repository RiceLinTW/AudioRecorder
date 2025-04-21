import Foundation

public protocol RecordingUseCases {
  func startRecording(fileName: String) async throws
  func stopRecording() async throws -> Recording
  func playRecording(_ recording: Recording) async throws
  func pauseRecording() async
  func deleteRecording(_ recording: Recording) async throws
  func getAllRecordings() async throws -> [Recording]
  func getRecordingTranscript(_ recording: Recording) async throws -> String
  func getRecordingSummary(_ recording: Recording) async throws -> String
}

public final class RecordingInteractor: RecordingUseCases {
  private let repository: RecordingRepository
  private let audioManager: AudioManager
  
  public init(repository: RecordingRepository, audioManager: AudioManager) {
    self.repository = repository
    self.audioManager = audioManager
  }
  
  public func startRecording(fileName: String) async throws {
    try await audioManager.startRecording(fileName: fileName)
  }
  
  public func stopRecording() async throws -> Recording {
    audioManager.stopRecording()
    let recording = Recording(
      fileName: "", // 需要從 AudioManager 獲取
      duration: audioManager.currentTime
    )
    try await repository.saveRecording(recording)
    return recording
  }
  
  public func playRecording(_ recording: Recording) async throws {
    try audioManager.startPlayback(fileURL: recording.fileURL)
  }
  
  public func pauseRecording() async {
    audioManager.pausePlayback()
  }
  
  public func deleteRecording(_ recording: Recording) async throws {
    try await repository.deleteRecording(recording)
    try FileManager.default.removeItem(at: recording.fileURL)
  }
  
  public func getAllRecordings() async throws -> [Recording] {
    try await repository.getAllRecordings()
  }
  
  public func getRecordingTranscript(_ recording: Recording) async throws -> String {
    // TODO: 實作 Heph PaaS API 呼叫
    fatalError("Not implemented")
  }
  
  public func getRecordingSummary(_ recording: Recording) async throws -> String {
    // TODO: 實作 Ollama API 呼叫
    fatalError("Not implemented")
  }
} 