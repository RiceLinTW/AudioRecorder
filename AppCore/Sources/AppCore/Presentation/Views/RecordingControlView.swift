import SwiftUI

struct RecordingControlView: View {
  @ObservedObject var viewModel: RecorderViewModel
  
  var body: some View {
    VStack(spacing: 24) {
      // 時間顯示
      Text(viewModel.timeString(time: viewModel.recordingTime))
        .font(.system(size: 54, weight: .thin, design: .monospaced))
        .contentTransition(.numericText())
        .animation(.smooth, value: viewModel.recordingTime)
      
      // 錄音按鈕
      Button {
        if viewModel.isRecording {
          viewModel.stopRecording()
        } else {
          viewModel.startRecording()
        }
      } label: {
        Image(systemName: viewModel.isRecording ? "stop.circle.fill" : "record.circle")
          .font(.system(size: 72))
          .foregroundStyle(viewModel.isRecording ? .red : .accentColor)
          .symbolEffect(.bounce, value: viewModel.isRecording)
      }
      
      // 轉錄狀態
      if viewModel.isTranscribing {
        HStack {
          ProgressView()
            .controlSize(.small)
          Text("正在轉錄...")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
      }
    }
    .padding()
    .background {
      RoundedRectangle(cornerRadius: 16, style: .continuous)
        .fill(.background)
        .shadow(radius: 20, y: 10)
    }
  }
} 