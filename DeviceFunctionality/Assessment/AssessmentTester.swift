//
//  DeviceAssessment.swift
//  DeviceAssessment
//
//  Created by Uwais Alqadri on 15/12/23.
//

import Foundation
import UIKit

public protocol AssessmentDriver {
  var hasAssessmentPassed: [Assessment: Bool] { get }
  var assessments: [Assessment: Any] { get }
  
  func startAssessment(for type: Assessment, completion: (() -> Void)?)
  func stopAssessment(for type: Assessment)
}

public extension AssessmentDriver {
  func startAssessment(for type: Assessment, completion: (() -> Void)? = nil) { completion?() }
  func stopAssessment(for type: Assessment) {}
}

public struct AssessmentTester {
  public let driver: AssessmentDriver
  
  public init(driver: AssessmentDriver) {
    self.driver = driver
  }
  
  public init(driver: AssessmentDriverType) {
    switch driver {
    case .connectivity:
      self.driver = ConnectivityAssessment()
    case .deviceInfo:
      self.driver = DeviceInfoAssessment()
    case .physicalActivity:
      self.driver = PhysicalActivityAssessment()
    case .power:
      self.driver = PowerAssessment()
    }
  }
  
  public enum AssessmentDriverType {
    case connectivity
    case deviceInfo
    case physicalActivity
    case power
  }
}
