import Foundation

public enum OllamaAPIError: LocalizedError {
  case invalidURL
  case networkError(Error)
  case invalidResponse
  case decodingError(Error)
  case apiError(String)
  
  public var errorDescription: String? {
    switch self {
      case .invalidURL:
        "無效的 URL"
      case .networkError(let error):
        "網路錯誤：\(error.localizedDescription)"
      case .invalidResponse:
        "無效的回應格式"
      case .decodingError(let error):
        "解碼錯誤：\(error.localizedDescription)"
      case .apiError(let message):
        "API 錯誤：\(message)"
    }
  }
}

public class OllamaAPI {
  private let baseURL = "{your_ollama_host_url}"
  private let session: URLSession
  
  public init() {
    let config = URLSessionConfiguration.default
    config.timeoutIntervalForRequest = 300  // 5 分鐘
    config.timeoutIntervalForResource = 300 // 5 分鐘
    self.session = URLSession(configuration: config)
  }
  
  struct GenerateRequest: Codable {
    let model: String
    let prompt: String
    let stream: Bool
  }
  
  struct GenerateResponse: Codable {
    let model: String
    let response: String
    let done: Bool
  }
  
  public func generateSummary(text: String, model: String = "llama2:7b") async throws -> String {
    guard baseURL != "{your_ollama_host_url}" else {
      print("❌ Ollama API baseURL 尚未設定")
      throw OllamaAPIError.apiError("Ollama API baseURL 尚未設定")
    }

    print("🤖 開始生成摘要...")
    let url = URL(string: "\(baseURL)/api/generate")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let prompt = """
    請幫我用繁體中文總結以下內容的重點：
    
    \(text)
    
    請用條列式回答，每個重點不要超過 30 字。最多不要超過 5 個重點。
    """
    
    let generateRequest = GenerateRequest(
      model: model,
      prompt: prompt,
      stream: false
    )
    
    let encoder = JSONEncoder()
    request.httpBody = try encoder.encode(generateRequest)
    
    print("🌐 發送請求到 Ollama API...")
    let (data, response) = try await session.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse else {
      print("❌ 無效的回應格式")
      throw OllamaAPIError.invalidResponse
    }
    
    print("📡 收到回應: HTTP \(httpResponse.statusCode)")
    
    guard httpResponse.statusCode == 200 else {
      if let errorString = String(data: data, encoding: .utf8) {
        print("❌ API 錯誤: \(errorString)")
      }
      throw OllamaAPIError.apiError("HTTP \(httpResponse.statusCode)")
    }
    
    do {
      let result = try JSONDecoder().decode(GenerateResponse.self, from: data)
      print("✅ 摘要生成完成！")
      return result.response
    } catch let error as DecodingError {
      print("❌ 回應解碼失敗")
      throw OllamaAPIError.decodingError(error)
    }
  }
} 
