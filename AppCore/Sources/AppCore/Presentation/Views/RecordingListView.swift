import SwiftUI

struct RecordingListView: View {
  let recordings: [RecordingModel]
  let onSelect: (RecordingModel) -> Void
  let onDelete: (RecordingModel) -> Void
  let onTranscribe: (RecordingModel) async throws -> Void
  let onSummarize: (RecordingModel) async throws -> Void
  @State private var errorMessage: String?
  @State private var showError = false
  
  var body: some View {
    List {
      ForEach(recordings) { recording in
        RecordingItemView(
          recording: recording,
          onTranscribe: {
            Task {
              do {
                try await onTranscribe(recording)
              } catch {
                errorMessage = error.localizedDescription
                showError = true
              }
            }
          },
          onSummarize: {
            Task {
              do {
                try await onSummarize(recording)
              } catch {
                errorMessage = error.localizedDescription
                showError = true
              }
            }
          }
        )
        .contentShape(Rectangle())
        .onTapGesture {
          onSelect(recording)
        }
      }
      .onDelete { indexSet in
        indexSet.forEach { index in
          onDelete(recordings[index])
        }
      }
    }
    .listStyle(.plain)
    .alert("錯誤", isPresented: $showError) {
      Button("確定") {
        errorMessage = nil
      }
    } message: {
      if let message = errorMessage {
        Text(message)
      }
    }
  }
}

struct RecordingItemView: View {
  let recording: RecordingModel
  let onTranscribe: () -> Void
  let onSummarize: () -> Void
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text(recording.title)
          .font(.headline)
        Spacer()
        Text(recording.createdAt.formatted(date: .abbreviated, time: .shortened))
          .font(.caption)
          .foregroundStyle(.secondary)
      }
      
      if let transcript = recording.transcript {
        Text(transcript)
          .lineLimit(2)
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
      
      if let summary = recording.summary {
        VStack(alignment: .leading, spacing: 4) {
          Text("重點摘要")
            .font(.caption)
            .foregroundStyle(.secondary)
          Text(summary)
            .font(.callout)
            .padding(8)
            .background(Color.secondary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
      }
      
      HStack(spacing: 16) {
        Label("\(recording.duration.formatted(.number.precision(.fractionLength(1)))) 秒", systemImage: "clock")
        
        if recording.transcript == nil {
          if let progress = recording.progress {
            HStack(spacing: 4) {
              ProgressView()
                .controlSize(.small)
              Text(progress)
                .font(.caption)
            }
          } else {
            Button(action: onTranscribe) {
              Label("轉錄", systemImage: "text.bubble")
            }
            .buttonStyle(.bordered)
            .tint(.blue)
          }
        } else if recording.summary == nil {
          Button(action: onSummarize) {
            Label("摘要", systemImage: "text.redaction")
          }
          .buttonStyle(.bordered)
          .tint(.green)
        }
      }
      .font(.caption)
      .foregroundStyle(.secondary)
    }
    .padding(.vertical, 4)
  }
} 