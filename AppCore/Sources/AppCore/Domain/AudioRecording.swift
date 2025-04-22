import Foundation

struct AudioRecording: Identifiable {
  let id: UUID
  let url: URL
  let createdAt: Date
  var duration: TimeInterval
  
  init(id: UUID = UUID(), url: URL, duration: TimeInterval = 0) {
    self.id = id
    self.url = url
    self.createdAt = Date()
    self.duration = duration
  }
} 