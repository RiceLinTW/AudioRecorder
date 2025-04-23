import Foundation
import SwiftData

@Model
final class RecordingModel: @unchecked Sendable {
  var id: UUID
  var title: String
  var createdAt: Date
  var duration: TimeInterval
  var filename: String
  var transcript: String?
  var summary: String?
  var progress: String?
  var isSummarizing: Bool = false
  
  var filePath: String {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
      .appendingPathComponent(filename)
      .path
  }
  
  init(
    id: UUID = UUID(),
    title: String,
    createdAt: Date = Date(),
    duration: TimeInterval,
    filename: String,
    transcript: String? = nil,
    summary: String? = nil,
    progress: String? = nil,
    isSummarizing: Bool = false
  ) {
    self.id = id
    self.title = title
    self.createdAt = createdAt
    self.duration = duration
    self.filename = filename
    self.transcript = transcript
    self.summary = summary
    self.progress = progress
    self.isSummarizing = isSummarizing
  }
} 
