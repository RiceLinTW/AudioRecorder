import Foundation
import SwiftData

@Model
final class RecordingModel: Sendable {
  var id: UUID
  var title: String
  var createdAt: Date
  var duration: TimeInterval
  var filePath: String
  var transcript: String?
  var summary: String?
  
  init(
    id: UUID = UUID(),
    title: String,
    createdAt: Date = Date(),
    duration: TimeInterval,
    filePath: String,
    transcript: String? = nil,
    summary: String? = nil
  ) {
    self.id = id
    self.title = title
    self.createdAt = createdAt
    self.duration = duration
    self.filePath = filePath
    self.transcript = transcript
    self.summary = summary
  }
} 