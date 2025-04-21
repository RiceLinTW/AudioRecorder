import Foundation
import SwiftData

@MainActor
public final class SwiftDataRecordingRepository: RecordingRepository {
  private let container: ModelContainer
  private let context: ModelContext
  
  public init(context: ModelContext) {
    self.container = context.container
    self.context = context
  }
  
  public init() throws {
    self.container = try ModelContainer(
      for: AudioRecording.self,
      configurations: ModelConfiguration(isStoredInMemoryOnly: false)
    )
    self.context = self.container.mainContext
  }
  
  public func getAllRecordings() async throws -> [Recording] {
    let descriptor = FetchDescriptor<AudioRecording>(
      sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
    )
    let audioRecordings = try context.fetch(descriptor)
    return audioRecordings.map { audioRecording in
      Recording(
        id: audioRecording.id,
        fileName: audioRecording.fileName,
        createdAt: audioRecording.createdAt,
        duration: audioRecording.duration,
        transcript: audioRecording.transcript,
        summary: audioRecording.summary
      )
    }
  }
  
  public func saveRecording(_ recording: Recording) async throws {
    let audioRecording = AudioRecording(
      id: recording.id,
      fileName: recording.fileName,
      createdAt: recording.createdAt,
      duration: recording.duration,
      transcript: recording.transcript,
      summary: recording.summary
    )
    context.insert(audioRecording)
    try context.save()
  }
  
  public func deleteRecording(_ recording: Recording) async throws {
    let id = recording.id
    let predicate = #Predicate<AudioRecording> { $0.id == id }
    let descriptor = FetchDescriptor<AudioRecording>(
      predicate: predicate
    )
    let audioRecordings = try context.fetch(descriptor)
    guard let audioRecording = audioRecordings.first else { return }
    context.delete(audioRecording)
    try context.save()
  }
  
  public func updateRecording(_ recording: Recording) async throws {
    let id = recording.id
    let predicate = #Predicate<AudioRecording> { $0.id == id }
    let descriptor = FetchDescriptor<AudioRecording>(
      predicate: predicate
    )
    let audioRecordings = try context.fetch(descriptor)
    guard let audioRecording = audioRecordings.first else { return }
    
    audioRecording.fileName = recording.fileName
    audioRecording.duration = recording.duration
    audioRecording.transcript = recording.transcript
    audioRecording.summary = recording.summary
    
    try context.save()
  }
  
  public func getRecording(byId id: UUID) async throws -> Recording? {
    let descriptor = FetchDescriptor<AudioRecording>(
      predicate: #Predicate<AudioRecording> { $0.id == id }
    )
    let audioRecordings = try context.fetch(descriptor)
    guard let audioRecording = audioRecordings.first else { return nil }
    
    return Recording(
      id: audioRecording.id,
      fileName: audioRecording.fileName,
      createdAt: audioRecording.createdAt,
      duration: audioRecording.duration,
      transcript: audioRecording.transcript,
      summary: audioRecording.summary
    )
  }
} 
