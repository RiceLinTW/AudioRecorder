import Foundation
import AVFoundation

class AVPlayerObserver: NSObject, AVAudioPlayerDelegate {
  static let shared = AVPlayerObserver()
  var onEnd: (() -> Void)?
  
  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    if flag {
      onEnd?()
    }
  }
} 