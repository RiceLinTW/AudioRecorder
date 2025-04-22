//
//  ContentView.swift
//  TestRecorder
//
//  Created by Rice Lin on 4/22/25.
//

import AVFoundation
import SwiftUI

public struct ContentView: View {
  @State private var audioRecorder: AVAudioRecorder?
  @State private var audioPlayer: AVAudioPlayer?
  @State private var isRecording = false
  @State private var isPlaying = false
  @State private var recordingURL: URL?
  @State private var recordingTime: TimeInterval = 0
  @State private var timer: Timer?
  
  public init() {}
    
  public var body: some View {
    VStack(spacing: 20) {
      Text("錄音應用")
        .font(.largeTitle)
        .fontWeight(.bold)
        .padding(.top, 30)
            
      Spacer()
            
      // 錄音時間顯示
      Text(timeString(time: recordingTime))
        .font(.system(size: 54, weight: .medium, design: .monospaced))
        .foregroundColor(isRecording ? .red : .primary)
            
      Spacer()
            
      // 控制按鈕
      HStack(spacing: 40) {
        // 錄音按鈕
        Button(action: {
          if isRecording {
            stopRecording()
          } else {
            startRecording()
          }
        }) {
          ZStack {
            Circle()
              .fill(isRecording ? Color.red.opacity(0.3) : Color.red)
              .frame(width: 70, height: 70)
              .shadow(radius: 5)
                        
            if isRecording {
              RoundedRectangle(cornerRadius: 4)
                .fill(Color.white)
                .frame(width: 20, height: 20)
            } else {
              Circle()
                .fill(Color.white)
                .frame(width: 25, height: 25)
            }
          }
        }
                
        // 播放按鈕
        Button(action: {
          if isPlaying {
            stopPlayback()
          } else {
            startPlayback()
          }
        }) {
          ZStack {
            Circle()
              .fill(Color.blue)
              .frame(width: 70, height: 70)
              .shadow(radius: 5)
                        
            if isPlaying {
              RoundedRectangle(cornerRadius: 4)
                .fill(Color.white)
                .frame(width: 20, height: 20)
            } else {
              Image(systemName: "play.fill")
                .foregroundColor(.white)
                .font(.system(size: 25))
            }
          }
        }
        .disabled(recordingURL == nil)
        .opacity(recordingURL == nil ? 0.5 : 1)
                
        // 重置按鈕
        Button(action: {
          resetRecording()
        }) {
          ZStack {
            Circle()
              .fill(Color.gray)
              .frame(width: 70, height: 70)
              .shadow(radius: 5)
                        
            Image(systemName: "arrow.counterclockwise")
              .foregroundColor(.white)
              .font(.system(size: 25))
          }
        }
        .disabled(recordingURL == nil)
        .opacity(recordingURL == nil ? 0.5 : 1)
      }
            
      Spacer()
            
      Text(recordingURL != nil ? "錄音已保存" : "尚無錄音")
        .foregroundColor(.secondary)
        .padding(.bottom, 20)
    }
    .padding()
    .onAppear {
      setupRecorder()
    }
  }
    
  // 設置錄音機
  private func setupRecorder() {
    let audioSession = AVAudioSession.sharedInstance()
        
    do {
      try audioSession.setCategory(.playAndRecord, mode: .default)
      try audioSession.setActive(true)
            
      // 請求錄音權限
      audioSession.requestRecordPermission { allowed in
        if !allowed {
          print("錄音權限被拒絕")
        }
      }
    } catch {
      print("設置音頻會話失敗: \(error.localizedDescription)")
    }
  }
    
  // 開始錄音
  private func startRecording() {
    let audioSession = AVAudioSession.sharedInstance()
        
    do {
      try audioSession.setActive(true)
            
      let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
      let audioFilename = documentsPath.appendingPathComponent("recording.m4a")
      recordingURL = audioFilename
            
      let settings = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 44100,
        AVNumberOfChannelsKey: 2,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
      ]
            
      audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
      audioRecorder?.record()
            
      isRecording = true
      recordingTime = 0
            
      // 設置計時器
      timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
        recordingTime += 0.1
      }
    } catch {
      print("錄音失敗: \(error.localizedDescription)")
    }
  }
    
  // 停止錄音
  private func stopRecording() {
    audioRecorder?.stop()
    isRecording = false
    timer?.invalidate()
  }
    
  // 開始播放
  private func startPlayback() {
    guard let url = recordingURL else { return }
        
    do {
      audioPlayer = try AVAudioPlayer(contentsOf: url)
      audioPlayer?.delegate = AVPlayerObserver.shared
      AVPlayerObserver.shared.onEnd = {
        isPlaying = false
      }
      audioPlayer?.play()
      isPlaying = true
    } catch {
      print("播放失敗: \(error.localizedDescription)")
    }
  }
    
  // 停止播放
  private func stopPlayback() {
    audioPlayer?.stop()
    isPlaying = false
  }
    
  // 重置錄音
  private func resetRecording() {
    if isPlaying {
      stopPlayback()
    }
        
    recordingURL = nil
    recordingTime = 0
  }
    
  // 格式化時間
  private func timeString(time: TimeInterval) -> String {
    let minutes = Int(time) / 60
    let seconds = Int(time) % 60
    let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 10)
    return String(format: "%02d:%02d.%01d", minutes, seconds, milliseconds)
  }
}

// AVAudioPlayer 代理觀察者
class AVPlayerObserver: NSObject, AVAudioPlayerDelegate {
  static let shared = AVPlayerObserver()
  var onEnd: (() -> Void)?
    
  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    if flag {
      onEnd?()
    }
  }
}

#Preview {
  ContentView()
}
