import SwiftUI
import DataStore
import AudioService

public struct RecorderView: View {
  @StateObject private var viewModel: RecorderViewModel
  @StateObject private var authService = AuthService.shared
  @State private var showError = false
  @State private var errorMessage: String?
  @State private var showLoginSheet = false
  
  public init() {
    let repository = DefaultAudioRecorderRepository()
    let recordingStore = RecordingStoreActor()
    self._viewModel = StateObject(wrappedValue: RecorderViewModel(
      repository: repository,
      recordingStore: recordingStore
    ))
  }
  
  public var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        // 錄音列表
        RecordingListView(
          recordings: viewModel.recordings,
          onSelect: { recording in
            // TODO: 顯示詳細資訊
          },
          onDelete: { recording in
            Task { @MainActor in
              do {
                try await viewModel.deleteRecording(recording)
              } catch {
                errorMessage = error.localizedDescription
                showError = true
              }
            }
          },
          onTranscribe: { recording in
            try await viewModel.startTranscription(recording)
          },
          onSummarize: { recording in
            try await viewModel.startSummary(recording)
          },
          onUpdateSummary: { recording, summary in
            try await viewModel.updateSummary(recording, summary: summary)
          },
          onPlay: { recording in
            try await viewModel.playRecording(recording)
          }
        )
        
        // 底部控制器
        RecordingControlView(viewModel: viewModel)
          .padding()
          .background(Color(.systemBackground))
      }
      .navigationTitle("錄音")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          if authService.isLoggedIn {
            HStack(spacing: 8) {
              Text(authService.username ?? "")
                .foregroundColor(.secondary)
              Button {
                authService.logout()
              } label: {
                Text("logout", bundle: .module)
              }
            }
          } else {
            Button {
              showLoginSheet = true
            } label: {
              Text("login", bundle: .module)
            }
          }
        }
      }
      .alert("錯誤", isPresented: $showError) {
        Button {
          errorMessage = nil
        } label: {
          Text("ok", bundle: .module)
        }
      } message: {
        if let message = errorMessage {
          Text(message)
        }
      }
      .onChange(of: viewModel.error) { _, error in
        if let error {
          errorMessage = error.localizedDescription
          showError = true
        }
      }
      .sheet(isPresented: $showLoginSheet) {
        LoginView()
      }
    }
  }
} 

#Preview("繁體中文") {
  RecorderView()
    .environment(\.locale, .init(identifier: "zh-Hant"))
}
#Preview("English") {
  RecorderView()
}
