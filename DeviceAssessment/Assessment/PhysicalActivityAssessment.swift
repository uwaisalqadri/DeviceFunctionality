//
//  PhysicalActivityAssessment.swift
//  DeviceAssessment
//
//  Created by Uwais Alqadri on 25/12/23.
//

import Foundation

class PhysicalActivityAssessment: AssessmentDriver {
  private var volumeButtonHandler: JPSVolumeButtonHandler?
    
  deinit {
    volumeButtonHandler?.stop()
  }
  
  var hasAssessmentPassed: [Assessment: Bool] {
    var results: [Assessment: Bool] =  [:]
    
    if let assessment = assessments[.volumeUpButton] as? Bool {
      results[.volumeUpButton] = assessment
    } else {
      results[.volumeUpButton] = false
    }
    
    if let assessment = assessments[.volumeDownButton] as? Bool {
      results[.volumeDownButton] = assessment
    } else {
      results[.volumeDownButton] = false
    }
    
    return results
  }
  
  var assessments: [Assessment: Any] = [
    .volumeUpButton: false,
    .volumeDownButton: false
  ]
  
  func startAssessment(completion: (() -> Void)? = nil) {
    volumeButtonHandler = JPSVolumeButtonHandler(up: { [weak self] in
      self?.assessments[.volumeUpButton] = true
      completion?()
      
    }, downBlock: { [weak self] in
      self?.assessments[.volumeDownButton] = true
      completion?()
      
    })
    
    volumeButtonHandler?.start(true)
  }
}
