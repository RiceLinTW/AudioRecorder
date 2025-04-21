import Foundation

public protocol RecordingRepository {
  func getAllRecordings() async throws -> [Recording]
  func saveRecording(_ recording: Recording) async throws
  func deleteRecording(_ recording: Recording) async throws
  func updateRecording(_ recording: Recording) async throws
  func getRecording(byId id: UUID) async throws -> Recording?
} 