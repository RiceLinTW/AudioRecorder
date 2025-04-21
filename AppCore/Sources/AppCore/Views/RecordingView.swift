import SwiftUI

public struct RecordingView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel: RecordingViewModel
  let onComplete: (Recording) -> Void
  
  public init(viewModel: RecordingViewModel, onComplete: @escaping (Recording) -> Void) {
    _viewModel = StateObject(wrappedValue: viewModel)
    self.onComplete = onComplete
  }
  
  public var body: some View {
    NavigationStack {
      VStack {
        Spacer()
        
        // 波形動畫視圖
        WaveformView(isRecording: viewModel.isRecording)
          .frame(height: 100)
          .padding()
        
        // 錄音時間
        Text(formatDuration(viewModel.currentTime))
          .font(.system(size: 54, weight: .thin, design: .monospaced))
          .padding()
        
        // 錄音按鈕
        Button {
          Task {
            if viewModel.isRecording {
              if let recording = await viewModel.stopRecording() {
                onComplete(recording)
                dismiss()
              }
            } else {
              await viewModel.startRecording()
            }
          }
        } label: {
          ZStack {
            Circle()
              .fill(viewModel.isRecording ? .red : .accentColor)
              .frame(width: 80, height: 80)
            
            Circle()
              .strokeBorder(.white, lineWidth: 4)
              .frame(width: 72, height: 72)
            
            if viewModel.isRecording {
              RoundedRectangle(cornerRadius: 4)
                .fill(.white)
                .frame(width: 32, height: 32)
            }
          }
        }
        .padding()
        
        Spacer()
      }
      .navigationTitle("錄音")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("取消") {
            dismiss()
          }
        }
      }
      .alert("錯誤", isPresented: .constant(viewModel.error != nil)) {
        Button("確定") {
          viewModel.clearError()
        }
      } message: {
        Text(viewModel.error?.localizedDescription ?? "")
      }
    }
  }
  
  private func formatDuration(_ duration: TimeInterval) -> String {
    let minutes = Int(duration) / 60
    let seconds = Int(duration) % 60
    return String(format: "%02d:%02d", minutes, seconds)
  }
}

// 波形動畫視圖
struct WaveformView: View {
  let isRecording: Bool
  
  var body: some View {
    GeometryReader { geometry in
      HStack(spacing: 4) {
        ForEach(0..<Int(geometry.size.width / 8), id: \.self) { index in
          RoundedRectangle(cornerRadius: 2)
            .fill(.blue.opacity(0.6))
            .frame(width: 4)
            .frame(height: isRecording ? randomHeight() : 10)
            .animation(
              .easeInOut(duration: 0.5)
              .repeatForever()
              .delay(Double(index) * 0.1),
              value: isRecording
            )
        }
      }
    }
  }
  
  private func randomHeight() -> CGFloat {
    CGFloat.random(in: 10...100)
  }
}

#Preview {
  RecordingView(viewModel: RecordingViewModel(useCase: PreviewRecordingInteractor())) { _ in }
} 