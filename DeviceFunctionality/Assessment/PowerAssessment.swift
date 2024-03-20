//
//  PowerAssessment.swift
//  DeviceAssessment
//
//  Created by Uwais Alqadri on 24/12/23.
//

import Foundation

public class PowerAssessment: NSObject, AssessmentDriver {
  public override init() {}
  
  public var hasAssessmentPassed: [Assessment: Bool] {
    return [.batteryStatus: true]
  }
  
  public var assessments: [Assessment: Any] = [:]
  
  public func startAssessment(for type: Assessment, completion: (() -> Void)? = nil) {
    if type == .batteryStatus {
      self.assessments[.batteryStatus] = Battery(
        voltage: "",
        technology: "",
        replacementStatus: "",
        status: "",
        health: "",
        temperature: ""
      )
      
      completion?()
    }
  }
}
