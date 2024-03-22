//
//  AssessmentPresenter.swift
//  DeviceAssessment
//
//  Created by Uwais Alqadri on 6/1/24.
//

import SwiftUI
import Combine
import DeviceKit
import AudioToolbox
import Foundation

class AssessmentPresenter: ObservableObject {
  
  @Published var currentAssessment: (assessment: Assessment, isRunning: Bool) = (.cpu, false)
  @Published var isAssessmentPassed = false
  
  private var cancellables = Set<AnyCancellable>()
  
  lazy var physicalDriver: AssessmentDriver = {
    return AssessmentTester(driver: .physicalActivity).driver
  }()
  
  lazy var deviceDriver: AssessmentDriver = {
    return AssessmentTester(driver: .deviceInfo).driver
  }()
  
  lazy var connectivityDriver: AssessmentDriver = {
    return AssessmentTester(driver: .connectivity).driver
  }()
  
  lazy var powerDriver: AssessmentDriver = {
    return AssessmentTester(driver: .power).driver
  }()
  
  func runningAssessment(for assessment: Assessment) {
    currentAssessment = (assessment, !assessment.testingMessage.isEmpty)
    startAssessment(for: assessment)
      .receive(on: RunLoop.main)
      .sink(
        receiveCompletion: { completion in
          if case .finished = completion {
            self.currentAssessment = (assessment, false)
          }
        },
        receiveValue: { isPassed in
          self.isAssessmentPassed = isPassed
        }
      )
      .store(in: &cancellables)
  }
  
  func startAssessment(for assessment: Assessment) -> AnyPublisher<Bool, Error> {
    return Future<Bool, Error> { promise in
      switch assessment {
      case .cpu:
        if let cpu = self.deviceDriver.assessments[assessment] as? CpuInformation {
          promise(.success(cpu.model?.isEmpty != true))
        }
        
      case .storage:
        self.deviceDriver.startAssessment(for: assessment) {
          if let storage = self.deviceDriver.assessments[assessment] as? Storage {
            promise(.success(storage.totalSpace?.isEmpty != true))
          }
        }
        
      case .batteryStatus:
        if let battery = self.powerDriver.assessments[assessment] as? Battery {
          promise(.success(battery.technology?.isEmpty != true))
        }
        
      case .rootStatus:
        promise(.success(self.deviceDriver.hasAssessmentPassed[assessment] ?? false))
        
      case .volumeUp, .volumeDown, .silentSwitch, .biometric, .proximity, .accelerometer, .microphone:
        self.physicalDriver.startAssessment(for: assessment) {
          if let reason = self.physicalDriver.assessments[.biometric] as? BiometricFailedReason {
            promise(.failure(reason))
            return
          }
          
          if let failure = self.physicalDriver.assessments[.microphone] as? PermissionFailed {
            promise(.failure(failure))
            return
          }
          
          promise(.success(self.physicalDriver.hasAssessmentPassed[assessment] ?? false))
        }
      case .powerButton:
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
          .map { _ in true }
          .sink { isTriggered in
            let oldBrightness = UIScreen.main.brightness
            let newBrightness = max(0.01, min(1.0, oldBrightness + (oldBrightness <= 0.01 ? 0.01 : -0.01)))
            UIScreen.main.brightness = newBrightness
            promise(.success(abs(oldBrightness - newBrightness) > 0.001))
          }
          .store(in: &self.cancellables)
        
      case .camera:
        promise(.success(true))
        
      case .touchscreen:
        promise(.success(true))
        
      case .sim, .wifi, .bluetooth, .gps:
        self.connectivityDriver.startAssessment(for: assessment) {
          promise(.success(self.connectivityDriver.hasAssessmentPassed[assessment] ?? false))
        }
        
      case .homeButton:
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
          .map { _ in true }
          .sink { isTriggered in
            promise(.success(isTriggered))
          }
          .store(in: &self.cancellables)
        
      case .mainSpeaker, .earSpeaker, .vibration:
        self.physicalDriver.startAssessment(for: assessment) {
          promise(.success(true))
        }
        
      case .deadpixel:
        promise(.success(true))
        
      case .rotation:
        NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
          .map { _ in true }
          .sink { isTriggered in
            promise(.success(isTriggered))
          }
          .store(in: &self.cancellables)
        
      }
    }
    .eraseToAnyPublisher()
  }
}
