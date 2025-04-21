import Foundation
import SwiftUI

@MainActor
public final class RecordingViewModel: ObservableObject {
  @Published public private(set) var isRecording = false
  @Published public private(set) var currentTime: TimeInterval = 0
  @Published public private(set) var error: Error?
  
  private let useCase: RecordingUseCases
  private var currentFileName: String?
  
  public init(useCase: RecordingUseCases) {
    self.useCase = useCase
  }
  
  public func startRecording() async {
    do {
      let fileName = "\(Date().timeIntervalSince1970).m4a"
      currentFileName = fileName
      try await useCase.startRecording(fileName: fileName)
      isRecording = true
      error = nil
    } catch {
      self.error = error
    }
  }
  
  public func stopRecording() async -> Recording? {
    do {
      isRecording = false
      let recording = try await useCase.stopRecording()
      error = nil
      return recording
    } catch {
      self.error = error
      return nil
    }
  }
  
  public func getCurrentFileName() -> String? {
    currentFileName
  }
  
  public func clearError() {
    error = nil
  }
} 