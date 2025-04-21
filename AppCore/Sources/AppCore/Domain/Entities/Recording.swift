import Foundation

public struct Recording: Identifiable {
  public let id: UUID
  public let fileName: String
  public let createdAt: Date
  public let duration: TimeInterval
  public let transcript: String?
  public let summary: String?
  
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