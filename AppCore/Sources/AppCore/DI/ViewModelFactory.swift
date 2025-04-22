import Foundation

@MainActor
class ViewModelFactory {
  static let shared = ViewModelFactory()
  private let repository: AudioRecorderRepository
  
  private init() {
    self.repository = DefaultAudioRecorderRepository()
  }
  
  func makeRecorderViewModel() async -> RecorderViewModel {
    await RecorderViewModel(repository: repository)
  }
} 