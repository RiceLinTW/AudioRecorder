@testable import AudioService
@testable import DataStore
import Testing
import XCTest

final class AudioServiceTests {
  @Test func testRecordingError() {
    let error = RecorderError.recording("Test error")
    XCTAssertEqual(error.errorDescription, "錄音錯誤：Test error")
  }
  
  @Test func testPlaybackError() {
    let error = RecorderError.playback("Test error")
    XCTAssertEqual(error.errorDescription, "播放錯誤：Test error")
  }
  
  @Test func testDeletionError() {
    let error = RecorderError.deletion("Test error")
    XCTAssertEqual(error.errorDescription, "刪除錯誤：Test error")
  }
  
  @Test func testTranscriptionError() {
    let error = RecorderError.transcription("Test error")
    XCTAssertEqual(error.errorDescription, "轉錄錯誤：Test error")
  }
}
