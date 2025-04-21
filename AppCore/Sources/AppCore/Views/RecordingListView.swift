import SwiftUI
import SwiftData

public struct RecordingListView: View {
  @StateObject private var viewModel: RecordingListViewModel
  @State private var isRecording = false
  
  public init(viewModel: RecordingListViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }
  
  public var body: some View {
    NavigationStack {
      Group {
        if viewModel.isLoading {
          ProgressView()
        } else {
          List {
            ForEach(viewModel.recordings) { recording in
              RecordingRow(recording: recording, viewModel: viewModel)
                .swipeActions(allowsFullSwipe: true) {
                  Button(role: .destructive) {
                    Task {
                      await viewModel.deleteRecording(recording)
                    }
                  } label: {
                    Label("刪除", systemImage: "trash")
                  }
                }
            }
          }
        }
      }
      .navigationTitle("錄音清單")
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          Button {
            isRecording.toggle()
          } label: {
            Label("錄音", systemImage: isRecording ? "stop.circle.fill" : "record.circle")
          }
          .tint(isRecording ? .red : .accentColor)
        }
      }
      .sheet(isPresented: $isRecording) {
        RecordingView(viewModel: viewModel.makeRecordingViewModel()) { recording in
          Task {
            await viewModel.loadRecordings()
          }
        }
      }
      .task {
        await viewModel.loadRecordings()
      }
      .alert("錯誤", isPresented: Binding(
        get: { viewModel.error != nil },
        set: { _ in viewModel.clearError() }
      )) {
        Button("確定") {
          viewModel.clearError()
        }
      } message: {
        if let error = viewModel.error {
          Text(error.localizedDescription)
        }
      }
    }
  }
}

struct RecordingRow: View {
  let recording: Recording
  let viewModel: RecordingListViewModel
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Text(recording.fileName)
          .font(.headline)
        Spacer()
        Text(recording.createdAt.formatted(date: .numeric, time: .shortened))
          .font(.caption)
          .foregroundStyle(.secondary)
      }
      
      HStack {
        Button {
          Task {
            await viewModel.playRecording(recording)
          }
        } label: {
          Label("播放", systemImage: "play.fill")
        }
        .buttonStyle(.bordered)
        
        Text(formatDuration(recording.duration))
      }
    }
    .padding(.vertical, 4)
  }
  
  private func formatDuration(_ duration: TimeInterval) -> String {
    let minutes = Int(duration) / 60
    let seconds = Int(duration) % 60
    return String(format: "%d:%02d", minutes, seconds)
  }
}

#Preview {
  RecordingListView(viewModel: RecordingListViewModel(useCase: PreviewRecordingInteractor()))
} 