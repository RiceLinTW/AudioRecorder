import SwiftUI

struct ricer: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var authService = AuthService.shared
  @State private var email = ""
  @State private var password = ""
  @State private var apiKey = ""
  @State private var isLoading = false
  @State private var showError = false
  
  var body: some View {
    NavigationView {
      Form {
        Section("認證資訊") {
          TextField("Email", text: $email)
            .textContentType(.emailAddress)
            .autocapitalization(.none)
          
          SecureField("密碼", text: $password)
            .textContentType(.password)
          
          TextField("API Key", text: $apiKey)
            .autocapitalization(.none)
            .textInputAutocapitalization(.never)
        }
        
        Button(action: login) {
          if isLoading {
            ProgressView()
          } else {
            Text("登入")
          }
        }
        .disabled(email.isEmpty || password.isEmpty || apiKey.isEmpty || isLoading)
      }
      .navigationTitle("登入 Heph")
      .alert("登入失敗", isPresented: $showError) {
        Button("確定", role: .cancel) { }
      } message: {
        Text(authService.error ?? "未知錯誤")
      }
    }
  }
  
  private func login() {
    isLoading = true
    Task {
      do {
        try await authService.login(email: email, password: password, apiKey: apiKey)
        dismiss()
      } catch {
        showError = true
      }
      isLoading = false
    }
  }
} 
