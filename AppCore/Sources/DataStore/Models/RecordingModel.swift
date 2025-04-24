import Foundation
import SwiftData

@Model
public final class RecordingModel: @unchecked Sendable {
  public var id: UUID
  public var title: String
  public var createdAt: Date
  public var duration: TimeInterval
  public var filename: String
  public var transcript: String?
  public var summary: String?
  public var progress: String?
  public var isSummarizing: Bool = false
  
  public var filePath: String {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
      .appendingPathComponent(filename)
      .path
  }
  
  public init(
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