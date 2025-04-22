import Foundation

@MainActor
class ViewModelFactory {
  static let shared = ViewModelFactory()
  private let repository: AudioRecorderRepository
  private let recordingStore: RecordingStoreActor
  
  private init() {
    self.repository = DefaultAudioRecorderRepository()
    self.recordingStore = RecordingStoreActor()
  }
  
  func makeRecorderViewModel() async -> RecorderViewModel {
    await RecorderViewModel(repository: repository, recordingStore: recordingStore)
  }
} 
