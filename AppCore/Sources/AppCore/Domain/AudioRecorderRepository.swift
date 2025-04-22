import Foundation

protocol AudioRecorderRepository {
  func startRecording() throws
  func stopRecording() -> AudioRecording?
  func deleteRecording(_ recording: AudioRecording) throws
  func getRecordingURL() -> URL?
} 