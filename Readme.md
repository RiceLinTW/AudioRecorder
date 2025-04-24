# AudioRecorder

iOS 錄音重點整理 APP，提供錄音、播放、逐字稿轉換與 AI 重點摘要整理功能。

## 系統需求

- iOS 17.0+
- Xcode 15.0+
- macOS 14.0+
- Docker (用於 Ollama API)
- ngrok (用於本地開發)

## 專案結構

```
AudioRecorder/
├── AppCore/                 # 核心功能模組
│   ├── Sources/
│   │   ├── NetworkService/ # 網路服務
│   │   │   ├── API/       # API 實作
│   │   │   ├── Models/    # 資料模型
│   │   │   └── Services/  # 服務層
│   │   ├── AudioService/   # 音訊處理
│   │   ├── DataStore/      # 資料儲存
│   │   └── AppCore/        # 核心功能
│   └── Package.swift       # SPM 設定
├── AudioRecorder/          # iOS APP
├── AudioRecorderTests/     # 單元測試
└── AudioRecorderUITests/   # UI 測試
```

## 功能特色

- 錄音與播放
  - 支援背景錄音
  - 音檔本地管理
- 語音轉文字（Heph PaaS）
  - 支援中文/英文辨識
  - 背景轉寫功能
- AI 摘要生成（Ollama）
  - 自動重點整理
  - 可編輯摘要內容
- 多語系支援
  - 繁體中文
  - 英文

## 開發環境設定

1. 複製專案：
```bash
git clone [repository_url]
cd AudioRecorder
```

2. 開啟專案：
```bash
open AudioRecorder.xcodeproj
```

## 模組說明

- **AppCore**: 核心功能整合
  - 多語系資源
  - 相依性注入
  - UI 元件
- **NetworkService**: API 整合
  - Heph PaaS 串接
  - Ollama API 串接
- **AudioService**: 音訊處理
  - 錄音功能
  - 播放功能
  - 音檔管理
- **DataStore**: 資料儲存
  - 檔案管理
  - 設定儲存
  - 資料模型

## API 設定

### Heph PaaS API
- 首次使用時需要登入取得授權
- 支援 email/password 登入
- 在設定頁面輸入 API Key

### Ollama API
1. 本地部署：
```bash
# 安裝並啟動 Docker
brew install docker
docker run -d -p 11434:11434 ollama/ollama

# 設定 ngrok 通道
brew install ngrok
ngrok http 11434
```

2. 更新 ngrok URL：
在 `AppCore/Sources/NetworkService/API/OllamaAPI.swift` 中更新 `baseURL`：
```swift
private let baseURL = "your_ollama_host_url"
```

## 相依套件

- **ZIPFoundation**: 音檔壓縮與解壓縮
  - 版本: 0.9.0+
  - 用途: 處理音檔上傳壓縮

## 授權說明

本專案採用 MIT 授權。詳見 [LICENSE](LICENSE) 文件。 