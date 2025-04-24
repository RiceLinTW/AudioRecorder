import Foundation
import ZIPFoundation

enum HephAPIError: LocalizedError {
  case invalidURL
  case networkError(Error)
  case invalidResponse
  case decodingError(Error)
  case apiError(code: String, message: String)
  case authError(String)
  case fileError(String)
  case zipError(String)
  
  var errorDescription: String? {
    switch self {
      case .invalidURL:
        "無效的 URL"
      case .networkError(let error):
        "網路錯誤：\(error.localizedDescription)"
      case .invalidResponse:
        "無效的回應格式"
      case .decodingError(let error):
        "解碼錯誤：\(error.localizedDescription)"
      case .apiError(let code, let message):
        "API 錯誤 [\(code)]: \(message)"
      case .authError(let message):
        "認證錯誤：\(message)"
      case .fileError(let message):
        "檔案錯誤：\(message)"
      case .zipError(let message):
        "ZIP 錯誤：\(message)"
    }
  }
}

class HephAPI {
  private let baseURL = Config.hephBaseURL
  private var accessToken: String? {
    get { UserDefaults.standard.string(forKey: "accessToken") }
    set { UserDefaults.standard.set(newValue, forKey: "accessToken") }
  }
  
  struct LoginResponse: Codable {
    let statusCode: String
    let message: String
    let data: LoginData
    
    struct LoginData: Codable {
      let user: User
      let tokens: Tokens
      
      struct User: Codable {
        let _id: String
        let name: String
        let roles: [Role]
        let profilePicUrl: String
        
        struct Role: Codable {
          let _id: String
          let code: String
        }
      }
      
      struct Tokens: Codable {
        let accessToken: String
        let refreshToken: String
      }
    }
  }
  
  struct TranscriptionTask: Codable {
    let data: TranscriptionData
    let statusCode: String
    let message: String
    
    struct TranscriptionData: Codable {
      let task_id: String
    }
  }

  struct TranscriptionStatus: Codable {
    let data: TranscriptionStatusData
    let statusCode: String
    let message: String
    
    struct TranscriptionStatusData: Codable {
      let status: String
      let progress: String
      let exception_traceback: String
      let text: String
      let filePaths: TranscriptionFilePath
        
      struct TranscriptionFilePath: Codable {
        let audio_path: String?
        let srt_path: String?
        let tsv_path: String?
        let txt_path: String?
        let vtt_path: String?
        let archive_path: String?
      }
    }
  }
  
  struct TranscriptionResult {
    let text: String
    let segments: [TranscriptionSegment]
  }
  
  struct TranscriptionSegment: Codable {
    let start: Double
    let end: Double
    let text: String
  }
  
  public func login() async throws {
    print("🔐 開始登入...")
    let url = URL(string: "\(baseURL)/v1/login")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(Config.apiKey, forHTTPHeaderField: "x-api-key")
    
    let email = ProcessInfo.processInfo.environment["HEPH_EMAIL"] ?? ""
    let password = ProcessInfo.processInfo.environment["HEPH_PASSWORD"] ?? ""
    
    let body = [
      "email": email,
      "password": password
    ]
    request.httpBody = try JSONSerialization.data(withJSONObject: body)
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse else {
      print("❌ 登入失敗：無效的回應格式")
      throw HephAPIError.invalidResponse
    }
    
    print("📡 登入回應: HTTP \(httpResponse.statusCode)")
    print(String(data: data, encoding: .utf8) ?? "?????")
    do {
      let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
      
      if loginResponse.statusCode != "10000" {
        print("❌ 登入失敗: \(loginResponse.message)")
        throw HephAPIError.apiError(code: loginResponse.statusCode, message: loginResponse.message)
      }
      
      accessToken = loginResponse.data.tokens.accessToken
      print("✅ 登入成功！")
    } catch let error as DecodingError {
      print("❌ 登入回應解碼失敗")
      print(error)
      throw HephAPIError.decodingError(error)
    }
  }
  
  private func authorizedRequest(_ request: inout URLRequest) {
    request.setValue(Config.apiKey, forHTTPHeaderField: "x-api-key")
    if let token = accessToken {
      request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
  }
  
  func uploadAudio(fileURL: URL, model: String = "small") async throws -> TranscriptionTask {
    if accessToken == nil {
      try await login()
    }
    
    print("🎤 開始上傳音檔: \(fileURL.lastPathComponent)")
    
    guard FileManager.default.fileExists(atPath: fileURL.path) else {
      throw HephAPIError.fileError("找不到音檔：\(fileURL.path)")
    }
    
    let url = URL(string: "\(baseURL)/v1/hear/file")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    authorizedRequest(&request)
    
    let boundary = UUID().uuidString
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    
    var data = Data()
    data.append("--\(boundary)\r\n".data(using: .utf8)!)
    data.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
    data.append("Content-Type: audio/wav\r\n\r\n".data(using: .utf8)!)
    
    print("📦 讀取音檔資料...")
    let fileData: Data
    do {
      fileData = try Data(contentsOf: fileURL)
    } catch {
      throw HephAPIError.fileError("讀取音檔失敗：\(error.localizedDescription)")
    }
    print("📊 音檔大小: \(fileData.count) bytes")
    
    data.append(fileData)
    data.append("\r\n".data(using: .utf8)!)
    data.append("--\(boundary)\r\n".data(using: .utf8)!)
    data.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n".data(using: .utf8)!)
    data.append("\(model)\r\n".data(using: .utf8)!)
    data.append("--\(boundary)--\r\n".data(using: .utf8)!)
    
    request.httpBody = data
    
    print("🌐 發送請求到 Heph API...")
    let (responseData, response) = try await URLSession.shared.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
      print("❌ 無效的回應格式")
      throw HephAPIError.invalidResponse
    }
    
    print("📡 收到回應: HTTP \(httpResponse.statusCode)")
    
    do {
      if httpResponse.statusCode != 200 {
        let errorResponse = try JSONDecoder().decode(LoginResponse.self, from: responseData)
        throw HephAPIError.apiError(code: errorResponse.statusCode, message: errorResponse.message)
      }
      
      let task = try JSONDecoder().decode(TranscriptionTask.self, from: responseData)
      print("✅ 上傳成功! Task ID: \(task.data.task_id)")
      return task
    } catch let error as DecodingError {
      print("❌ 回應解碼失敗")
      throw HephAPIError.decodingError(error)
    }
  }
  
  func checkStatus(taskID: String) async throws -> TranscriptionStatus {
    if accessToken == nil {
      try await login()
    }
    
    print("🔍 檢查轉錄狀態: \(taskID)")
    let url = URL(string: "\(baseURL)/v1/hear/status/\(taskID)")!
    var request = URLRequest(url: url)
    authorizedRequest(&request)
    
    let (data, response) = try await URLSession.shared.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
      print("❌ 無效的回應格式")
      throw HephAPIError.invalidResponse
    }
    
    print("📡 收到狀態回應: HTTP \(httpResponse.statusCode)")

    do {
      if httpResponse.statusCode != 200 {
        let errorResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
        throw HephAPIError.apiError(code: errorResponse.statusCode, message: errorResponse.message)
      }
      
      let status = try JSONDecoder().decode(TranscriptionStatus.self, from: data)
      print("📊 轉錄進度: \(status.data.status) (\(status.data.progress)")
      return status
    } catch let error as DecodingError {
      print("❌ 回應解碼失敗")
      throw HephAPIError.decodingError(error)
    }
  }
  
  func getResult(taskID: String) async throws -> TranscriptionResult {
    if accessToken == nil {
      try await login()
    }
    
    print("📥 取得轉錄結果: \(taskID)")
    let url = URL(string: "\(baseURL)/v1/hear/result/\(taskID)")!
    var request = URLRequest(url: url)
    authorizedRequest(&request)
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse else {
      print("❌ 無效的回應格式")
      throw HephAPIError.invalidResponse
    }
    
    print("📡 收到結果回應: HTTP \(httpResponse.statusCode)")
    
    guard httpResponse.statusCode == 200 else {
      if let errorString = String(data: data, encoding: .utf8) {
        print("❌ API 錯誤: \(errorString)")
      }
      throw HephAPIError.apiError(code: "\(httpResponse.statusCode)", message: "下載失敗")
    }
    
    // 建立暫存目錄
    let fileManager = FileManager.default
    let tempDir = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true)
    
    // 儲存 ZIP 檔案
    let zipPath = tempDir.appendingPathComponent("\(taskID).zip")
    try data.write(to: zipPath)
    
    print("📦 解壓縮檔案...")
    let unzipDir = tempDir.appendingPathComponent("unzip")
    try fileManager.createDirectory(at: unzipDir, withIntermediateDirectories: true)
    
    // 解壓縮
    let archive = try Archive(url: zipPath, accessMode: .read)
    
    // 讀取 txt 檔案
    let txtFileName = "\(taskID).txt"
    guard let txtEntry = archive[txtFileName] else {
      throw HephAPIError.zipError("找不到文字檔：\(txtFileName)")
    }
    
    var transcriptText = ""
    _ = try archive.extract(txtEntry) { data in
      if let text = String(data: data, encoding: .utf8) {
        transcriptText += text
      }
    }
    
    // 讀取 srt 檔案來取得時間軸
    let srtFileName = "\(taskID).srt"
    guard let srtEntry = archive[srtFileName] else {
      throw HephAPIError.zipError("找不到字幕檔：\(srtFileName)")
    }
    
    var segments: [TranscriptionSegment] = []
    _ = try archive.extract(srtEntry) { data in
      if let srtContent = String(data: data, encoding: .utf8) {
        segments.append(contentsOf: parseSRT(srtContent))
      }
    }
    
    // 清理暫存檔案
    try fileManager.removeItem(at: tempDir)
    
    return TranscriptionResult(text: transcriptText, segments: segments)
  }
  
  private func parseSRT(_ content: String) -> [TranscriptionSegment] {
    var segments: [TranscriptionSegment] = []
    let lines = content.components(separatedBy: .newlines)
    var index = 0
    
    while index < lines.count {
      // 跳過字幕編號
      index += 1
      guard index < lines.count else { break }
      
      // 解析時間軸
      let timeLine = lines[index]
      let times = timeLine.components(separatedBy: " --> ")
      guard times.count == 2,
            let start = parseTime(times[0]),
            let end = parseTime(times[1]) else {
        index += 1
        continue
      }
      
      // 讀取字幕文字
      index += 1
      var text = ""
      while index < lines.count && !lines[index].isEmpty {
        if !text.isEmpty {
          text += " "
        }
        text += lines[index]
        index += 1
      }
      
      if !text.isEmpty {
        segments.append(TranscriptionSegment(start: start, end: end, text: text))
      }
      
      // 跳過空行
      index += 1
    }
    
    return segments
  }
  
  private func parseTime(_ timeString: String) -> Double? {
    let components = timeString.components(separatedBy: ":")
    guard components.count == 3 else { return nil }
    
    let hourMinute = components[0...1].compactMap { Int($0) }
    guard hourMinute.count == 2 else { return nil }
    
    let secondMillis = components[2].components(separatedBy: ",")
    guard secondMillis.count == 2,
          let seconds = Int(secondMillis[0]),
          let millis = Int(secondMillis[1]) else { return nil }
    
    return Double(hourMinute[0] * 3600 + hourMinute[1] * 60 + seconds) + Double(millis) / 1000.0
  }
}
