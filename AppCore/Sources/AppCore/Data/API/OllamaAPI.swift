import Foundation

enum OllamaAPIError: Error {
  case invalidURL
  case networkError(Error)
  case invalidResponse
  case decodingError(Error)
  case apiError(String)
}

struct OllamaAPI {
  // 這邊需要再配合host修改
  private let baseURL = "https://8d53-118-169-19-211.ngrok-free.app"
  
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
  
  func generateSummary(text: String, model: String = "llama2:7b") async throws -> String {
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
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse else {
      throw OllamaAPIError.invalidResponse
    }
    
    guard httpResponse.statusCode == 200 else {
      throw OllamaAPIError.apiError("HTTP \(httpResponse.statusCode)")
    }

    let result = try JSONDecoder().decode(GenerateResponse.self, from: data)
    return result.response
  }
} 
