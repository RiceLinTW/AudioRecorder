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
      
      // 控制按鈕
      HStack(spacing: 32) {
        // 重置按鈕
        Button {
          viewModel.resetRecording()
        } label: {
          Image(systemName: "trash")
            .font(.title2)
            .foregroundStyle(.red)
            .frame(width: 44, height: 44)
            .background(.red.opacity(0.1))
            .clipShape(Circle())
        }
        .opacity(viewModel.currentRecording != nil ? 1 : 0)
        
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
        .disabled(viewModel.isPlaying)
        
        // 播放按鈕
        Button {
          if viewModel.isPlaying {
            viewModel.stopPlayback()
          } else {
            viewModel.startPlayback()
          }
        } label: {
          Image(systemName: viewModel.isPlaying ? "stop.fill" : "play.fill")
            .font(.title2)
            .foregroundStyle(viewModel.isPlaying ? .red : .accentColor)
            .frame(width: 44, height: 44)
            .background(Color.accentColor.opacity(0.1))
            .clipShape(Circle())
        }
        .opacity(viewModel.currentRecording != nil ? 1 : 0)
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