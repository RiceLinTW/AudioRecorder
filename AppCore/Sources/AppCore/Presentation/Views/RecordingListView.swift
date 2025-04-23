import SwiftUI

struct RecordingListView: View {
  let recordings: [RecordingModel]
  let onSelect: (RecordingModel) -> Void
  let onDelete: (RecordingModel) -> Void
  let onTranscribe: (RecordingModel) async throws -> Void
  let onSummarize: (RecordingModel) async throws -> Void
  let onUpdateSummary: (RecordingModel, String) async throws -> Void
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
          },
          onUpdateSummary: { summary in
            Task {
              do {
                try await onUpdateSummary(recording, summary)
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
  let onUpdateSummary: (String) -> Void
  @State private var showingSummaryEdit = false
  @State private var errorMessage: String?
  @State private var showError = false
  
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
          HStack {
            Text("重點摘要")
              .font(.caption)
              .foregroundStyle(.secondary)
            Spacer()
            Button {
              showingSummaryEdit = true
            } label: {
              Image(systemName: "pencil")
                .font(.body)
                .padding(8)
                .background(.secondary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                  RoundedRectangle(cornerRadius: 8)
                    .stroke(.secondary.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.1), radius: 1, y: 1)
            }
            .buttonStyle(.plain)
          }
          Text(summary)
            .font(.callout)
            .lineLimit(3)
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
          if recording.isSummarizing {
            HStack(spacing: 4) {
              ProgressView()
                .controlSize(.small)
              Text("摘要生成中...")
                .font(.caption)
            }
          } else {
            Button(action: onSummarize) {
              Label("摘要", systemImage: "text.redaction")
            }
            .buttonStyle(.bordered)
            .tint(.green)
          }
        }
      }
      .font(.caption)
      .foregroundStyle(.secondary)
    }
    .padding(.vertical, 4)
    .sheet(isPresented: $showingSummaryEdit) {
      SummaryEditView(
        recording: recording,
        onSave: { newSummary in
          onUpdateSummary(newSummary)
          showingSummaryEdit = false
        },
        onCancel: {
          showingSummaryEdit = false
        }
      )
    }
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
