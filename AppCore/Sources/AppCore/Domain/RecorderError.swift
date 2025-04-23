import Foundation

enum RecorderError: LocalizedError, Equatable {
  case recording(String)
  case playback(String)
  case deletion(String)
  case transcription(String)
  
  var errorDescription: String? {
    switch self {
      case .recording(let message):
        return "錄音錯誤: \(message)"
      case .playback(let message):
        return "播放錯誤: \(message)"
      case .deletion(let message):
        return "刪除錯誤: \(message)"
      case .transcription(let message):
        return "轉錄錯誤: \(message)"
    }
  }
} 