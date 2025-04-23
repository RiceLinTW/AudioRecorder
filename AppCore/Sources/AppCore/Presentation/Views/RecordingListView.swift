import SwiftUI

struct RecordingListView: View {
  let recordings: [RecordingModel]
  let onSelect: (RecordingModel) -> Void
  let onDelete: (RecordingModel) -> Void
  
  var body: some View {
    List {
      ForEach(recordings) { recording in
        RecordingItemView(recording: recording)
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
  }
}

struct RecordingItemView: View {
  let recording: RecordingModel
  
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
          Label("轉錄中", systemImage: "arrow.triangle.2.circlepath")
            .foregroundStyle(.blue)
        }
      }
      .font(.caption)
      .foregroundStyle(.secondary)
    }
    .padding(.vertical, 4)
  }
} 