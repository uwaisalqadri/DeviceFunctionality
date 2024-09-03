//
//  FunctionalityPresenter.swift
//  DeviceAssessment
//
//  Created by Uwais Alqadri on 6/1/24.
//

import SwiftUI
import Combine
import DeviceKit
import AudioToolbox
import Foundation

@MainActor
class FunctionalityPresenter: ObservableObject {
  
  @Published var state = State()
  
  private lazy var physicalDriver: AssessmentDriver = {
    return AssessmentTester(driver: .physicalActivity).driver
  }()
  
  private lazy var deviceDriver: AssessmentDriver = {
    return AssessmentTester(driver: .deviceInfo).driver
  }()
  
  private lazy var connectivityDriver: AssessmentDriver = {
    return AssessmentTester(driver: .connectivity).driver
  }()
  
  private lazy var powerDriver: AssessmentDriver = {
    return AssessmentTester(driver: .power).driver
  }()
  
  private var cancellables = Set<AnyCancellable>()
  
  func send(_ action: Action) {
    switch action {
    case .didStart(let assessment):
      runningAssessment(for: assessment)
    }
  }
    
  func runningAssessment(for assessment: Assessment) {
    state.currentAssessment = (assessment, !assessment.testingMessage.isEmpty)
    state.isAssessmentPassed = false
    
    Task {
      for try await isAssessmentPassed in startAssessment(for: assessment) {
        self.state.currentAssessment = (assessment, false)
        self.state.isAssessmentPassed = isAssessmentPassed
      }
    }
  }
}

extension FunctionalityPresenter {
  
  @MainActor
  func startAssessment(for assessment: Assessment) ->  AsyncThrowingStream<Bool, Error> {
    return AsyncThrowingStream { continuation in
      switch assessment {
      case .cpu:
        if let cpu = self.deviceDriver.assessments[assessment] as? CpuInformation {
          continuation.yield(cpu.model?.isEmpty != true)
        }
        
      case .storage:
        self.deviceDriver.startAssessment(for: assessment) {
          if let storage = self.deviceDriver.assessments[assessment] as? Storage {
            continuation.yield(storage.totalSpace?.isEmpty != true)
          }
        }
        
      case .batteryStatus:
        if let battery = self.powerDriver.assessments[assessment] as? Battery {
          continuation.yield(battery.technology?.isEmpty != true)
        }
        
      case .rootStatus:
        continuation.yield(self.deviceDriver.hasAssessmentPassed[assessment] ?? false)
        
      case .volumeUp, .volumeDown, .biometric, .proximity, .accelerometer, .microphone:
        self.physicalDriver.startAssessment(for: assessment) {
          if let reason = self.physicalDriver.assessments[.biometric] as? BiometricFailedReason {
            continuation.finish(throwing: reason)
            return
          }
          
          if let failure = self.physicalDriver.assessments[.microphone] as? PermissionFailed {
            continuation.finish(throwing: failure)
            return
          }
          
          continuation.yield(self.physicalDriver.hasAssessmentPassed[assessment] ?? false)
          self.physicalDriver.stopAssessment(for: assessment)
        }
      case .silentSwitch:
        self.physicalDriver.startAssessment(for: assessment) {
          continuation.yield(self.physicalDriver.hasAssessmentPassed[assessment] ?? false)
          self.physicalDriver.stopAssessment(for: assessment)
        }
      case .powerButton:
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
          .map { _ in true }
          .sink { isTriggered in
            let oldBrightness = UIScreen.main.brightness
            let newBrightness = max(0.01, min(1.0, oldBrightness + (oldBrightness <= 0.01 ? 0.01 : -0.01)))
            UIScreen.main.brightness = newBrightness
            continuation.yield(abs(oldBrightness - newBrightness) > 0.001)
          }
          .store(in: &self.cancellables)
        
      case .camera:
        continuation.yield(true)
        
      case .touchscreen:
        continuation.yield(true)
        
      case .sim, .wifi, .bluetooth, .gps:
        self.connectivityDriver.startAssessment(for: assessment) {
          continuation.yield(self.connectivityDriver.hasAssessmentPassed[assessment] ?? false)
          self.connectivityDriver.stopAssessment(for: assessment)
        }
        
      case .homeButton:
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
          .map { _ in true }
          .sink { isTriggered in
            continuation.yield(isTriggered)
          }
          .store(in: &self.cancellables)
        
      case .mainSpeaker, .earSpeaker, .vibration:
        self.physicalDriver.startAssessment(for: assessment) {
          continuation.yield(true)
          self.physicalDriver.stopAssessment(for: assessment)
        }
        
      case .deadpixel:
        continuation.yield(true)
        
      case .rotation:
        NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
          .map { _ in true }
          .sink { isTriggered in
            continuation.yield(isTriggered)
          }
          .store(in: &self.cancellables)
        
      }
    }
  }
}
