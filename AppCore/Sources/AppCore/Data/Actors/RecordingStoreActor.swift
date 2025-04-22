import Foundation
import SwiftData

@ModelActor
actor RecordingStoreActor {
//  nonisolated let container: ModelContainer
  
  init() {
    let schema = Schema([RecordingModel.self])
    let modelConfiguration = ModelConfiguration(schema: schema)
    let modelContainer = try! ModelContainer(for: schema, configurations: [modelConfiguration])
    self.init(modelContainer: modelContainer)
  }
  
  func fetchAll() throws -> [RecordingModel] {
    let descriptor = FetchDescriptor<RecordingModel>()
    return try modelContext.fetch(descriptor)
  }
  
  func save(_ recording: AudioRecording) throws -> RecordingModel {
    let model = RecordingModel(
      id: recording.id,
      title: recording.url.lastPathComponent,
      createdAt: recording.createdAt,
      duration: recording.duration,
      filePath: recording.url.path
    )
    modelContext.insert(model)
    try modelContext.save()
    return model
  }
  
  func find(by id: UUID) throws -> RecordingModel? {
    let descriptor = FetchDescriptor<RecordingModel>(
      predicate: #Predicate<RecordingModel> { recording in
        recording.id == id
      }
    )
    return try modelContext.fetch(descriptor).first
  }
  
  func delete(_ recording: RecordingModel) throws {
    modelContext.delete(recording)
    try modelContext.save()
  }
  
  func update(_ recording: RecordingModel) throws {
    try modelContext.save()
  }
}
