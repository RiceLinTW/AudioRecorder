//
//  Item.swift
//  AudioRecorder
//
//  Created by Rice Lin on 4/18/25.
//

import Foundation
import SwiftData

@Model
public final class Item {
  var timestamp: Date

  init(timestamp: Date) {
    self.timestamp = timestamp
  }
}
