//
//  DeviceInfoAssessment.swift
//  DeviceAssessment
//
//  Created by Uwais Alqadri on 15/12/23.
//

import Foundation
import UIKit

struct DeviceInfoAssessment: AssessmentDriver {
  private var processInfo = ProcessInfo.processInfo
  private var device = UIDevice.current
  
  var hasAssessmentPassed: [Assessment: Bool] {
    var results: [Assessment: Bool] = [:]
    
    if let assessment = assessments[.cpu] as? CPUInformation {
      results[.cpu] = !assessment.name.isEmpty
    } else {
      results[.cpu] = false
    }
    
    if let assessment = assessments[.storage] as? Storage {
      results[.storage] = !assessment.totalRAMGB.isEmpty && !assessment.totalDiskSpaceGB.isEmpty
    } else {
      results[.storage] = false
    }
    
    if let assessment = assessments[.notJailbroken] as? Bool {
      results[.notJailbroken] = !assessment
    } else {
      results[.notJailbroken] = false
    }
    
    return results
  }
  
  var assessments: [Assessment: Any] {
    return [
      .cpu: CPUInformation(
        name: Array(device.cpuInfo.keys).first.orDefault,
        speed: Array(device.cpuInfo.values).first.orDefault
      ),
      .storage: Storage(
        totalRAMGB: Int64(processInfo.physicalMemory).toGBFormat(),
        totalDiskSpaceGB: device.totalDiskSpaceInBytes.toGBFormat()
      ),
      .notJailbroken: isJailbroken
    ]
  }
}

extension DeviceInfoAssessment {
  
  var isJailbroken: Bool {
    #if targetEnvironment(simulator)
    return false
    #else
    let fileManager = FileManager.default
    
    if (fileManager.fileExists(atPath: "/bin/bash") ||
        fileManager.fileExists(atPath: "/usr/sbin/sshd") ||
        fileManager.fileExists(atPath: "/etc/apt") ||
        fileManager.fileExists(atPath: "/private/var/lib/apt/") ||
        fileManager.fileExists(atPath: "/Applications/Cydia.app") ||
        fileManager.fileExists(atPath: "/Library/MobileSubstrate/MobileSubstrate.dylib")) {
      return true
    } else {
      return false
    }
    #endif
  }
  
  struct CPUInformation {
    var name: String
    var speed: String
  }
  
  struct Storage {
    var totalRAMGB: String
    var totalDiskSpaceGB: String
  }
  
}
