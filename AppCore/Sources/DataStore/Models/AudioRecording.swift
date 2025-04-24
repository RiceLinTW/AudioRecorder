import Foundation

public struct AudioRecording: Identifiable {
  public let id: UUID
  public let url: URL
  public let createdAt: Date
  public var duration: TimeInterval
  
  public init(id: UUID = UUID(), url: URL, duration: TimeInterval = 0) {
    self.id = id
    self.url = url
    self.createdAt = Date()
    self.duration = duration
  }
} 