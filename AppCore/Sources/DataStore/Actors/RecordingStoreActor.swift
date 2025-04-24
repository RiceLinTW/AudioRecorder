import Foundation
import SwiftData

@ModelActor
public actor RecordingStoreActor {
  public init() {
    let schema = Schema([RecordingModel.self])
    let modelConfiguration = ModelConfiguration(schema: schema)
    let modelContainer = try! ModelContainer(for: schema, configurations: [modelConfiguration])
    self.init(modelContainer: modelContainer)
  }
  
  public func fetchAll() throws -> [RecordingModel] {
    let descriptor = FetchDescriptor<RecordingModel>()
    return try modelContext.fetch(descriptor)
  }
  
  public func save(_ recording: AudioRecording) throws -> RecordingModel {
    let model = RecordingModel(
      id: recording.id,
      title: recording.url.lastPathComponent,
      createdAt: recording.createdAt,
      duration: recording.duration,
      filename: recording.url.lastPathComponent
    )
    modelContext.insert(model)
    try modelContext.save()
    return model
  }
  
  public func find(by id: UUID) throws -> RecordingModel? {
    let descriptor = FetchDescriptor<RecordingModel>(
      predicate: #Predicate<RecordingModel> { recording in
        recording.id == id
      }
    )
    return try modelContext.fetch(descriptor).first
  }
  
  public func delete(_ recording: RecordingModel) throws {
    modelContext.delete(recording)
    try modelContext.save()
  }
  
  public func update(_ recording: RecordingModel) throws {
    try modelContext.save()
  }
} 