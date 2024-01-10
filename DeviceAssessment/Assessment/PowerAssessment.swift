//
//  PowerAssessment.swift
//  DeviceAssessment
//
//  Created by Uwais Alqadri on 24/12/23.
//

import Foundation

class PowerAssessment: NSObject, AssessmentDriver {
  private var listener = UIDeviceListener.shared()
  var powerInformationUpdated: (() -> Void)?
  
  deinit {
    listener?.stop()
  }
  
  var hasAssessmentPassed: [Assessment: Bool] {
    guard let assessment = assessments[.batteryStatus] as? BatteryStatus
                        else { return [.batteryStatus: false] }
    return [.batteryStatus: assessment.batteryCycleCount < 100 && assessment.batteryHealth > 0.0]
  }
  
  var assessments: [Assessment: Any] = [:]
  
  func startAssessment(for type: Assessment, completion: (() -> Void)? = nil) {
    if type == .batteryStatus {
      listener?.start()
      NotificationCenter.default.addObserver(self, selector: #selector(listenerUpdated), name: Notification.Name(kUIDeviceListenerNewDataNotification), object: nil)
    }
  }
}

extension PowerAssessment {
  @objc private func listenerUpdated(_ notification: Notification) {
    let powerDictionary = notification.userInfo
    print("DEBUG: Batter", powerDictionary)
//    assessments = [
//      .batteryStatus: BatteryStatus(batteryMaxCapacity: powerInformation.batteryMaximumCapacity, batteryHealth: powerInformation.batteryHealth, batteryCycleCount: powerInformation.batteryCycleCount)
//    ]
  }
}

extension PowerAssessment {
  struct BatteryStatus {
    var batteryMaxCapacity: Int
    var batteryHealth: Float
    var batteryCycleCount: Int
  }
}
