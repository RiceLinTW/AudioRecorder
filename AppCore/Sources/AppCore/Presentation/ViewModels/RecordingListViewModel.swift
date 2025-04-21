import Foundation
import SwiftUI

@MainActor
public final class RecordingListViewModel: ObservableObject {
  @Published public private(set) var recordings: [Recording] = []
  @Published public private(set) var isLoading = false
  @Published public private(set) var error: Error?
  
  let useCase: RecordingUseCases
  
  public init(useCase: RecordingUseCases) {
    self.useCase = useCase
  }
  
  public func loadRecordings() async {
    isLoading = true
    do {
      recordings = try await useCase.getAllRecordings()
      error = nil
    } catch {
      self.error = error
    }
    isLoading = false
  }
  
  public func deleteRecording(_ recording: Recording) async {
    do {
      try await useCase.deleteRecording(recording)
      await loadRecordings()
      error = nil
    } catch {
      self.error = error
    }
  }
  
  public func playRecording(_ recording: Recording) async {
    do {
      try await useCase.playRecording(recording)
      error = nil
    } catch {
      self.error = error
    }
  }
  
  public func pauseRecording() async {
    await useCase.pauseRecording()
  }
  
  public func makeRecordingViewModel() -> RecordingViewModel {
    RecordingViewModel(useCase: useCase)
  }
  
  public func clearError() {
    error = nil
  }
} 