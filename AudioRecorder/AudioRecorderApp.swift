//
//  AudioRecorderApp.swift
//  AudioRecorder
//
//  Created by Rice Lin on 4/18/25.
//

import AppCore
import SwiftUI

@main
struct AudioRecorderApp: App {
  private let audioManager = AudioManager()
  private let repository: SwiftDataRecordingRepository
  
  init() {
    do {
      repository = try SwiftDataRecordingRepository()
    } catch {
      fatalError("Failed to create repository: \(error)")
    }
  }
  
  var body: some Scene {
    WindowGroup {
      RecordingListView(viewModel: RecordingListViewModel(
        useCase: RecordingInteractor(
          repository: repository,
          audioManager: audioManager
        )
      ))
    }
  }
}
