import Foundation
import SwiftData

@MainActor
public class PreviewData {
  static let shared = PreviewData()
  
  let container: ModelContainer
  let context: ModelContext
  
  private init() {
    do {
      container = try ModelContainer(
        for: AudioRecording.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
      )
      context = container.mainContext
      
      // 建立模擬資料
      let recordings = [
        AudioRecording(
          fileName: "會議記錄.m4a",
          createdAt: Date().addingTimeInterval(-3600),
          duration: 1825
        ),
        AudioRecording(
          fileName: "課程筆記.m4a",
          createdAt: Date().addingTimeInterval(-7200),
          duration: 2430
        ),
        AudioRecording(
          fileName: "備忘錄.m4a",
          createdAt: Date().addingTimeInterval(-86400),
          duration: 145
        )
      ]
      
      recordings.forEach { context.insert($0) }
    } catch {
      fatalError("Failed to create preview container: \(error)")
    }
  }
} 