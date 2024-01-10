//
//  DeviceAssessment.swift
//  DeviceAssessment
//
//  Created by Uwais Alqadri on 15/12/23.
//

import Foundation
import UIKit

enum Assessment: CaseIterable {
  case information
  case cpu
  case storage
  case ram
  case batteryStatus
  case notJailbroken
  case muteSwitch
  case volumeUpButton
  case volumeDownButton
  case powerButton
  case vibration
  case camera
  case touchScreen
  case sim
  case wifi
  case biometric
  case accelerometer  
}

protocol AssessmentDriver {
  var hasAssessmentPassed: [Assessment: Bool] { get }
  var assessments: [Assessment: Any] { get }
  
  func startAssessment(for type: Assessment, completion: (() -> Void)?)
}

extension AssessmentDriver {
  func startAssessment(for type: Assessment, completion: (() -> Void)? = nil) { completion?() }
}

struct AssessmentTester {
  let driver: AssessmentDriver
  
  init(driver: AssessmentDriver) {
    self.driver = driver
  }
}
