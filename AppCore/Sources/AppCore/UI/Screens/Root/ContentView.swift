//
//  ContentView.swift
//  TestRecorder
//
//  Created by Rice Lin on 4/22/25.
//

import AVFoundation
import SwiftUI

public struct ContentView: View {
  public init() {}
  
  public var body: some View {
    RecorderView()
      .preferredColorScheme(.dark)
      .tint(.orange)
  }
}

#Preview {
  ContentView()
}
