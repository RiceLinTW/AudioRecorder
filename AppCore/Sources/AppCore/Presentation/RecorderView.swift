import SwiftUI

public struct RecorderView: View {
  @State private var viewModel: RecorderViewModel?
  @State private var showError = false
  
  public init() {}
  
  public var body: some View {
    Group {
      if let viewModel = viewModel {
        RecorderContent(viewModel: viewModel)
          .alert("錯誤", isPresented: .constant(viewModel.error != nil)) {
            Button("確定") {
              viewModel.error = nil
            }
          } message: {
            if let error = viewModel.error {
              Text(error.localizedDescription)
            }
          }
      } else {
        ProgressView()
          .task {
            viewModel = await ViewModelFactory.shared.makeRecorderViewModel()
          }
      }
    }
  }
}

private struct RecorderContent: View {
  @ObservedObject var viewModel: RecorderViewModel
  
  var body: some View {
    NavigationStack {
      VStack(spacing: 20) {
        // 錄音時間顯示
        Text(viewModel.timeString(time: viewModel.recordingTime))
          .font(.system(size: 54, weight: .medium, design: .monospaced))
          .foregroundColor(viewModel.isRecording ? .red : .primary)
        
        // 控制按鈕
        HStack(spacing: 40) {
          // 錄音按鈕
          Button(action: {
            if viewModel.isRecording {
              viewModel.stopRecording()
            } else {
              viewModel.startRecording()
            }
          }) {
            ZStack {
              Circle()
                .fill(viewModel.isRecording ? Color.red.opacity(0.3) : Color.red)
                .frame(width: 70, height: 70)
                .shadow(radius: 5)
              
              if viewModel.isRecording {
                RoundedRectangle(cornerRadius: 4)
                  .fill(Color.white)
                  .frame(width: 20, height: 20)
              } else {
                Circle()
                  .fill(Color.white)
                  .frame(width: 25, height: 25)
              }
            }
          }
          
          // 播放按鈕
          Button(action: {
            if viewModel.isPlaying {
              viewModel.stopPlayback()
            } else {
              viewModel.startPlayback()
            }
          }) {
            ZStack {
              Circle()
                .fill(Color.blue)
                .frame(width: 70, height: 70)
                .shadow(radius: 5)
              
              if viewModel.isPlaying {
                RoundedRectangle(cornerRadius: 4)
                  .fill(Color.white)
                  .frame(width: 20, height: 20)
              } else {
                Image(systemName: "play.fill")
                  .foregroundColor(.white)
                  .font(.system(size: 25))
              }
            }
          }
          .disabled(viewModel.currentRecording == nil)
          .opacity(viewModel.currentRecording == nil ? 0.5 : 1)
          
          // 重置按鈕
          Button(action: {
            viewModel.resetRecording()
          }) {
            ZStack {
              Circle()
                .fill(Color.gray)
                .frame(width: 70, height: 70)
                .shadow(radius: 5)
              
              Image(systemName: "arrow.counterclockwise")
                .foregroundColor(.white)
                .font(.system(size: 25))
            }
          }
          .disabled(viewModel.currentRecording == nil)
          .opacity(viewModel.currentRecording == nil ? 0.5 : 1)
        }
        .padding(.vertical, 30)
        
        // 錄音列表
        List {
          ForEach(viewModel.recordings) { recording in
            RecordingRow(recording: recording)
          }
        }
        .listStyle(.plain)
      }
      .padding()
      .navigationTitle("錄音應用")
    }
  }
}

private struct RecordingRow: View {
  let recording: RecordingModel
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(recording.title)
        .font(.headline)
      
      HStack {
        Text(recording.createdAt.formatted())
          .font(.caption)
          .foregroundStyle(.secondary)
        
        Spacer()
        
        Text(String(format: "%.1f秒", recording.duration))
          .font(.caption)
          .foregroundStyle(.secondary)
      }
    }
    .padding(.vertical, 8)
  }
} 