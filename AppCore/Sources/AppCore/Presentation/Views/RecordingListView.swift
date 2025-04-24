import SwiftUI

struct RecordingListView: View {
  let recordings: [RecordingModel]
  let onSelect: (RecordingModel) -> Void
  let onDelete: (RecordingModel) -> Void
  let onTranscribe: (RecordingModel) async throws -> Void
  let onSummarize: (RecordingModel) async throws -> Void
  let onUpdateSummary: (RecordingModel, String) async throws -> Void
  let onPlay: (RecordingModel) async throws -> Void
  @State private var errorMessage: String?
  @State private var showError = false
  
  var body: some View {
    Group {
      if recordings.isEmpty {
        ContentUnavailableView(
          "還沒有錄音",
          systemImage: "waveform",
          description: Text("點擊下方的錄音按鈕開始錄製")
        )
        .symbolEffect(.bounce, value: recordings.isEmpty)
      } else {
        TabView {
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
              },
              onPlay: {
                Task {
                  do {
                    try await onPlay(recording)
                  } catch {
                    errorMessage = error.localizedDescription
                    showError = true
                  }
                }
              },
              onDelete: {
                onDelete(recording)
              }
            )
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
          }
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
      }
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

struct RecordingItemView: View {
  let recording: RecordingModel
  let onTranscribe: () -> Void
  let onSummarize: () -> Void
  let onUpdateSummary: (String) -> Void
  let onPlay: () -> Void
  let onDelete: () -> Void
  @State private var showingSummaryEdit = false
  @State private var errorMessage: String?
  @State private var showError = false
  @State private var showDeleteAlert = false
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Text(recording.title)
          .font(.title3)
          .fontWeight(.semibold)
        Spacer()
        Button(action: {
          showDeleteAlert = true
        }) {
          Image(systemName: "trash")
            .foregroundColor(.red)
        }
      }
      
      Text(recording.createdAt.formatted(date: .abbreviated, time: .shortened))
        .font(.caption)
        .foregroundStyle(.secondary)
      
      if let transcript = recording.transcript {
        Text(transcript)
          .lineLimit(3)
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .padding(.vertical, 4)
      }
      
      if let summary = recording.summary {
        VStack(alignment: .leading, spacing: 8) {
          HStack {
            Text("重點摘要")
              .font(.caption)
              .fontWeight(.medium)
              .foregroundStyle(.secondary)
            Spacer()
            Button {
              showingSummaryEdit = true
            } label: {
              Image(systemName: "pencil")
                .font(.body)
                .padding(8)
                .background(.secondary.opacity(0.1))
                .clipShape(Circle())
            }
            .buttonStyle(.plain)
          }
          Text(summary)
            .font(.callout)
            .lineLimit(4)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
      }
      
      Spacer(minLength: 16)
      
      HStack(spacing: 16) {
        Label("\(recording.duration.formatted(.number.precision(.fractionLength(1)))) 秒", systemImage: "clock")
          .font(.caption)
          .foregroundStyle(.secondary)
        
        Spacer()
        
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
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .controlSize(.small)
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
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .controlSize(.small)
          }
        }
      }
    }
    .padding(24)
    .background(Color(.systemBackground))
    .overlay(
      RoundedRectangle(cornerRadius: 16)
        .stroke(Color(.systemGray4), lineWidth: 1)
    )
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .shadow(
      color: .black.opacity(0.08),
      radius: 15,
      x: 0,
      y: 4
    )
    .shadow(
      color: .black.opacity(0.05),
      radius: 2,
      x: 0,
      y: 1
    )
    .contentShape(Rectangle())
    .onTapGesture {
      onPlay()
    }
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
    .alert("確認刪除", isPresented: $showDeleteAlert) {
      Button("刪除", role: .destructive) {
        onDelete()
      }
      Button("取消", role: .cancel) {}
    } message: {
      Text("確定要刪除這個錄音嗎？")
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
