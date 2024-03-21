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
 
  @Published var isCpuAssessment = false
  @Published var isStorageAssessment = false
  @Published var isSilentSwitchAssessment = false
  @Published var isSilentSwitched = false
  
  private var cancellables = Set<AnyCancellable>()
  
  func startAssessment(for assessment: Assessment) -> AnyPublisher<Bool, Error> {
    return Future<Bool, Error> { promise in
      switch assessment {
      case .cpu:
        self.assessment(driver: .deviceInfo).startAssessment(for: assessment) {
          if let cpu = self.assessment(driver: .deviceInfo).assessments[assessment] as? CpuInformation {
            promise(.success(cpu.model?.isEmpty != true))
          }
        }
      case .storage:
        self.assessment(driver: .deviceInfo).startAssessment(for: assessment) {
          if let storage = self.assessment(driver: .deviceInfo).assessments[assessment] as? Storage {
            promise(.success(storage.totalSpace?.isEmpty != true))
          }
        }
      case .batteryStatus:
        self.assessment(driver: .deviceInfo).startAssessment(for: assessment) {
          if let battery = self.assessment(driver: .deviceInfo).assessments[assessment] as? Battery {
            promise(.success(battery.technology?.isEmpty != true))
          }
        }
      case .rootStatus:
        if let device = self.assessment(driver: .deviceInfo).assessments[assessment] as? DeviceBasicInformation {
          promise(.success(device.isNotJailBroken))
        }
      case .volumeUp, .volumeDown, .silentSwitch, .biometric, .proximity, .accelerometer, .microphone:
        self.assessment(driver: .physicalActivity).startAssessment(for: assessment) {
          if let reason = self.assessment(driver: .physicalActivity).assessments[.biometric] as? BiometricFailedReason {
            promise(.failure(reason))
          }
          
          if let failure = self.assessment(driver: .physicalActivity).assessments[.microphone] as? PermissionFailed {
            promise(.failure(failure))
          }
          
          promise(.success(self.assessment(driver: .physicalActivity).hasAssessmentPassed[assessment] ?? false))
        }
      case .powerButton:
        let oldBrightness = UIScreen.main.brightness
        let newBrightness = max(0.01, min(1.0, oldBrightness + (oldBrightness <= 0.01 ? 0.01 : -0.01)))
        UIScreen.main.brightness = newBrightness
        promise(.success(abs(oldBrightness - newBrightness) > 0.001))
        
      case .camera:
        promise(.success(true))
      case .touchscreen:
        promise(.success(true))
      case .sim, .wifi, .bluetooth, .gps:
        self.assessment(driver: .connectivity).startAssessment(for: assessment) {
          promise(.success(self.assessment(driver: .connectivity).hasAssessmentPassed[assessment] ?? false))
        }
      case .homeButton:
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
          .map { _ in true }
          .sink { isTriggered in
            promise(.success(isTriggered))
          }
          .store(in: &self.cancellables)
      case .mainSpeaker, .earSpeaker, .vibration:
        self.assessment(driver: .physicalActivity).startAssessment(for: assessment)
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
  
  private func assessment(driver: AssessmentTester.AssessmentDriverType) -> AssessmentDriver {
    return AssessmentTester(driver: driver).driver
  }
}
