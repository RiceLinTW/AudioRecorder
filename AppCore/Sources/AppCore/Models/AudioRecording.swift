import Foundation
import SwiftData

@Model
public final class AudioRecording {
  public var id: UUID
  public var fileName: String
  public var createdAt: Date
  public var duration: TimeInterval
  public var transcript: String?
  public var summary: String?
  
  public init(
    id: UUID = UUID(),
    fileName: String,
    createdAt: Date = Date(),
    duration: TimeInterval = 0,
    transcript: String? = nil,
    summary: String? = nil
  ) {
    self.id = id
    self.fileName = fileName
    self.createdAt = createdAt
    self.duration = duration
    self.transcript = transcript
    self.summary = summary
  }
  
  public var fileURL: URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
      .appendingPathComponent(fileName)
  }
} 