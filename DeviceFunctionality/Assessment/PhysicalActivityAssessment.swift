//
//  PhysicalActivityAssessment.swift
//  DeviceAssessment
//
//  Created by Uwais Alqadri on 25/12/23.
//

import AVFoundation
import CoreMotion
import DeviceKit
import Foundation
import LocalAuthentication
import notify
import UIKit

public class PhysicalActivityAssessment: NSObject, AssessmentDriver {
  private var motionManager = CMMotionManager()
  private var biometricAuth = BiometricAuthentication()
  
  private var currentMuteStatus: Bool?
  private var previousButtonTap = Date()
  private let minimumTapInterval = 0.3
  
  private var onProximityDetected: ((Bool) -> Void)?
  
  public override init() {
    super.init()
  }
  
  public var hasAssessmentPassed: [Assessment: Bool] {
    var results: [Assessment: Bool] = [:]
    
    let assessmentTypes: [Assessment] = [
      .volumeUp,
      .volumeDown,
      .silentSwitch,
      .biometric,
      .powerButton,
      .proximity,
      .accelerometer,
      .microphone,
      .earSpeaker,
      .mainSpeaker
    ]
    
    for type in assessmentTypes {
      results[type] = assessments[type] as? Bool ?? false
    }
    
    return results
  }
  
  public lazy var assessments: [Assessment: Any] = [
    .silentSwitch: false,
    .volumeUp: false,
    .volumeDown: false,
    .biometric: false,
    .powerButton: false,
    .proximity: false,
    .accelerometer: motionManager.isAccelerometerAvailable,
    .microphone: false,
    .earSpeaker: false,
    .mainSpeaker: false
  ]
  
  public func startAssessment(for type: Assessment, completion: (() -> Void)? = nil) {
    switch type {
    case .silentSwitch:
      Mute.shared = Mute()
      Mute.shared.notify = { [weak self] muteStatus in
        guard let self = self else { return }
        if let currentMuteStatus = self.currentMuteStatus, currentMuteStatus != muteStatus {
          self.assessments[.silentSwitch] = true
          completion?()
        } else {
          self.currentMuteStatus = muteStatus
        }
      }
      
      Mute.shared.checkInterval = 1.0
      Mute.shared.alwaysNotify = true
      Mute.shared.check()
      
    case .volumeUp:
      VolumeButtonHandler.shared.volumeUpHandler = { [weak self] in
        self?.assessments[.volumeUp] = true
        completion?()
      }
      
    case .volumeDown:
      VolumeButtonHandler.shared.volumeDownHandler = { [weak self] in
        self?.assessments[.volumeDown] = true
        completion?()
      }
      
    case .biometric:
      if biometricAuth.canEvaluatePolicy() {
        biometricAuth.authenticateUser(type: Device.current.isTouchIDCapable ? .touchID : .faceID) { [weak self] reason, _ in
          guard let self = self, reason != .none else {
            self?.assessments[.biometric] = true
            completion?()
            return
          }
          
          self.assessments[.biometric] = reason
          completion?()
        }
      } else {
        self.assessments[.biometric] = BiometricFailedReason.biometricUnavailable
        completion?()
      }
      
    case .proximity:
      UIDevice.current.isProximityMonitoringEnabled = true
      if UIDevice.current.isProximityMonitoringEnabled {
        NotificationCenter.default.addObserver(self, selector: #selector(proximityChanged), name: UIDevice.proximityStateDidChangeNotification, object: nil)
      }
      onProximityDetected = { isDetected in
        self.assessments[.proximity] = isDetected
        UIDevice.current.isProximityMonitoringEnabled = false
        completion?()
      }
      
    case .microphone:
      checkMicrophonePermission(onGranted: {
        SpeechRecognizer.shared.startRecording()
        SpeechRecognizer.shared.voiceDetectedCallback = { error in
          if let error = error {
            if let failed = error as? PermissionFailed {
              self.assessments[.microphone] = failed
            } else {
              self.assessments[.microphone] = false
            }
          } else {
            self.assessments[.microphone] = true
          }
          completion?()
        }
      }, onDenied: {
        self.assessments[.microphone] = PermissionFailed.microphoneNotPermitted
        completion?()
      })
      
      
    default:
      break
    }
  }
  
  public func stopAssessment(for type: Assessment) {
    switch type {
    case .silentSwitch:
      Mute.shared = Mute()
    case .proximity:
      UIDevice.current.isProximityMonitoringEnabled = false
    case .microphone:
      SpeechRecognizer.shared.stopRecording()
    default:
      break
    }
  }
}

extension PhysicalActivityAssessment {
  @objc func proximityChanged(_ notification: Notification) {
    onProximityDetected?(notification.object != nil)
  }
  
  func checkMicrophonePermission(onGranted: @escaping () -> Void, onDenied: @escaping () -> Void) {
    switch AVAudioSession.sharedInstance().recordPermission {
    case .granted:
      onGranted()
    case .undetermined:
      AVAudioSession.sharedInstance().requestRecordPermission { isGranted in
        DispatchQueue.main.async {
          if isGranted {
            onGranted()
          } else {
            onDenied()
          }
        }
      }
    default:
      onDenied()
    }
  }
}
