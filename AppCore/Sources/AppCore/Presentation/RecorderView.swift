import SwiftUI

public struct RecorderView: View {
  @State private var viewModel: RecorderViewModel?
  
  public init() {}
  
  public var body: some View {
    Group {
      if let viewModel = viewModel {
        RecorderContent(viewModel: viewModel)
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
    VStack(spacing: 20) {
      Text("錄音應用")
        .font(.largeTitle)
        .fontWeight(.bold)
        .padding(.top, 30)
      
      Spacer()
      
      // 錄音時間顯示
      Text(viewModel.timeString(time: viewModel.recordingTime))
        .font(.system(size: 54, weight: .medium, design: .monospaced))
        .foregroundColor(viewModel.isRecording ? .red : .primary)
      
      Spacer()
      
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
      
      Spacer()
      
      Text(viewModel.currentRecording != nil ? "錄音已保存" : "尚無錄音")
        .foregroundColor(.secondary)
        .padding(.bottom, 20)
    }
    .padding()
  }
} 