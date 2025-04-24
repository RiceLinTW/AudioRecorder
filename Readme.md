# AudioRecorder

iOS 錄音重點整理 APP，提供錄音、播放、逐字稿轉換與 AI 重點摘要整理功能。

## 系統需求

- iOS 17.0+
- Xcode 15.0+
- macOS 14.0+

## 專案結構

```
AudioRecorder/
├── AppCore/                 # 核心功能模組
│   ├── Sources/
│   │   └── AppCore/
│   │       ├── Domain/     # 領域模型
│   │       ├── Data/       # 資料層
│   │       ├── UI/        # UI 元件
│   │       └── Presentation/ # 畫面邏輯
│   └── Package.swift       # SPM 設定
├── AudioRecorder/          # iOS APP
├── AudioRecorderTests/     # 單元測試
└── AudioRecorderUITests/   # UI 測試
```

## 功能特色

- 錄音與播放
- 錄音檔本地管理（新增/刪除）
- 語音轉文字（Heph PaaS）
- AI 摘要生成（Ollama）

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

## API 設定

### Heph PaaS API
- 首次使用時需要登入取得授權
- 支援 email/password 登入

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
在 `AppCore/Sources/AppCore/Data/API/OllamaAPI.swift` 中更新 `baseURL`：
```swift
private let baseURL = "your_ollama_host_url"
```

## 相依套件

- ZIPFoundation: 用於處理音檔壓縮

## 授權說明

本專案採用 MIT 授權。詳見 [LICENSE](LICENSE) 文件。 