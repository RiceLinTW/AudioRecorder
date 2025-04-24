import Foundation

@MainActor
final class AuthService: ObservableObject {
  static let shared = AuthService()
  private var hephAPI: HephAPI?
  
  @Published var isLoggedIn = false
  @Published var username: String?
  @Published var error: String?
  
  private init() {
    // 檢查是否有儲存的 token 和 API Key
    if let apiKey = UserDefaults.standard.string(forKey: "hephApiKey"),
       UserDefaults.standard.string(forKey: "accessToken") != nil {
      hephAPI = HephAPI(apiKey: apiKey)
      isLoggedIn = true
      username = UserDefaults.standard.string(forKey: "username")
    }
  }
  
  func login(email: String, password: String, apiKey: String) async throws {
    do {
      hephAPI = HephAPI(apiKey: apiKey)
      UserDefaults.standard.set(email, forKey: "hephEmail")
      UserDefaults.standard.set(password, forKey: "hephPassword")
      UserDefaults.standard.set(apiKey, forKey: "hephApiKey")
      
      try await hephAPI?.login()
      isLoggedIn = true
      username = email
      UserDefaults.standard.set(email, forKey: "username")
    } catch {
      self.error = error.localizedDescription
      throw error
    }
  }
  
  func logout() {
    isLoggedIn = false
    username = nil
    hephAPI = nil
    UserDefaults.standard.removeObject(forKey: "accessToken")
    UserDefaults.standard.removeObject(forKey: "username")
    UserDefaults.standard.removeObject(forKey: "hephEmail")
    UserDefaults.standard.removeObject(forKey: "hephPassword")
    UserDefaults.standard.removeObject(forKey: "hephApiKey")
  }
  
  func getAPI() -> HephAPI? {
    return hephAPI
  }
} 