//
//  PowerAssessment.swift
//  DeviceAssessment
//
//  Created by Uwais Alqadri on 24/12/23.
//

import Foundation

struct PowerAssessment: AssessmentDriver {
  private let powerInfo: EEPowerInformation
  
  init(powerInfo: EEPowerInformation) {
    self.powerInfo = powerInfo
  }
    
  var hasAssessmentPassed: [Assessment: Bool] {
    guard let assessment = assessments[.batteryStatus] as? BatteryStatus
                        else { return [.batteryStatus: false] }
    return [.batteryStatus: assessment.batteryCycleCount < 100 && assessment.batteryHealth > 0.0]
  }
  
  var assessments: [Assessment: Any] {
    return [
      .batteryStatus: BatteryStatus(batteryHealth: powerInfo.batteryHealth, batteryCycleCount: powerInfo.batteryCycleCount)
    ]
  }
}

extension PowerAssessment {
  
  struct BatteryStatus {
    var batteryHealth: Float
    var batteryCycleCount: Int
  }
}
