import SwiftUI

struct SummaryEditView: View {
  let recording: RecordingModel
  let onSave: (String) -> Void
  let onCancel: () -> Void
  @State private var editedSummary: String
  
  init(recording: RecordingModel, onSave: @escaping (String) -> Void, onCancel: @escaping () -> Void) {
    self.recording = recording
    self.onSave = onSave
    self.onCancel = onCancel
    self._editedSummary = State(initialValue: recording.summary ?? "")
  }
  
  var body: some View {
    NavigationStack {
      TextEditor(text: $editedSummary)
        .font(.body)
        .padding()
        .navigationTitle("編輯摘要")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .cancellationAction) {
            Button("取消", action: onCancel)
          }
          ToolbarItem(placement: .confirmationAction) {
            Button("儲存") {
              onSave(editedSummary)
            }
          }
        }
    }
  }
} 