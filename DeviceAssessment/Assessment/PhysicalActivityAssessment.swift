//
//  PhysicalActivityAssessment.swift
//  DeviceAssessment
//
//  Created by Uwais Alqadri on 25/12/23.
//

import Foundation
import CoreMotion
import LocalAuthentication
import UIKit

class PhysicalActivityAssessment: AssessmentDriver {
  private var motionManager = CMMotionManager()
  private var biometricAuth = BiometricIDAuth()
  private var volumeButtonHandler: JPSVolumeButtonHandler?
  private var biometricHandler: ((BiometricFailedReason) -> Void)?
  
  deinit {
    volumeButtonHandler?.stop()
  }
  
  var hasAssessmentPassed: [Assessment: Bool] {
    var results: [Assessment: Bool] = [:]
    
    let assessmentTypes: [Assessment] = [.volumeUpButton, .volumeDownButton, .muteSwitch, .biometric, .accelerometer]
    
    for type in assessmentTypes {
      results[type] = assessments[type] as? Bool ?? false
    }
    
    return results
  }
  
  lazy var assessments: [Assessment: Any] = [
    .muteSwitch: false,
    .volumeUpButton: false,
    .volumeDownButton: false,
    .biometric: false,
    .accelerometer: motionManager.isAccelerometerAvailable
  ]
  
  func startAssessment(for type: Assessment, completion: (() -> Void)? = nil) {
    switch type {
    case .muteSwitch:
      Mute.shared.notify = { [weak self] isMuted in
        self?.assessments[.muteSwitch] = isMuted
        completion?()
      }
      
      Mute.shared.checkInterval = 2.0
      Mute.shared.alwaysNotify = true
      Mute.shared.check()
      
    case .volumeUpButton:
      volumeButtonHandler = JPSVolumeButtonHandler(up: { [weak self] in
        self?.assessments[.volumeUpButton] = true
        completion?()
      }, downBlock: {})
      volumeButtonHandler?.start(true)
      
    case .volumeDownButton:
      volumeButtonHandler = JPSVolumeButtonHandler(up: {}, downBlock: { [weak self] in
        self?.assessments[.volumeDownButton] = true
        completion?()
      })
      volumeButtonHandler?.start(true)
      
    case .biometric:
      if biometricAuth.canEvaluatePolicy() {
        biometricAuth.authenticateUser { [weak self] reason, error in
          guard let self = self, reason != .none else {
            self?.assessments[.biometric] = true
            completion?()
            return
          }
          
          self.assessments[.biometric] = false
          self.biometricHandler?(reason)
          completion?()
        }
      }
      
    case .vibration:
      UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
      }
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
      }
      
    default:
      break
    }
  }
}
