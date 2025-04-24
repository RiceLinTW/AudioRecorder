import Foundation
import DataStore
import AudioService

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
    RecorderViewModel(repository: repository, recordingStore: recordingStore)
  }
} 
