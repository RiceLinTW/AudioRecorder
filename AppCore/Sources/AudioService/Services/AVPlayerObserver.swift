import Foundation
import AVFoundation

public class AVPlayerObserver: NSObject, AVAudioPlayerDelegate {
  public static let shared = AVPlayerObserver()
  public var onEnd: (() -> Void)?
  
  public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    if flag {
      onEnd?()
    }
  }
} 