import Foundation
import UserNotifications

class NotificationService {
  static let shared = NotificationService()
  
  private init() {
    requestAuthorization()
  }
  
  private func requestAuthorization() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
      if granted {
        print("✅ 通知權限已獲得")
      } else if let error {
        print("❌ 通知權限請求失敗: \(error.localizedDescription)")
      }
    }
  }
  
  func scheduleTranscriptionNotification(title: String) {
    let content = UNMutableNotificationContent()
    content.title = "轉錄完成"
    content.body = "\(title) 的轉錄已完成"
    content.sound = .default
    
    let request = UNNotificationRequest(
      identifier: UUID().uuidString,
      content: content,
      trigger: nil
    )
    
    UNUserNotificationCenter.current().add(request) { error in
      if let error {
        print("❌ 發送通知失敗: \(error.localizedDescription)")
      }
    }
  }
  
  func scheduleSummaryNotification(title: String) {
    let content = UNMutableNotificationContent()
    content.title = "摘要完成"
    content.body = "\(title) 的重點摘要已完成"
    content.sound = .default
    
    let request = UNNotificationRequest(
      identifier: UUID().uuidString,
      content: content,
      trigger: nil
    )
    
    UNUserNotificationCenter.current().add(request) { error in
      if let error {
        print("❌ 發送通知失敗: \(error.localizedDescription)")
      }
    }
  }
} 