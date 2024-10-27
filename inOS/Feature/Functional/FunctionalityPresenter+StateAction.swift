//
//  FunctionalityPresenter+StateAction.swift
//  DeviceFunctionality
//
//  Created by Uwais Alqadri on 03/09/24.
//

import Foundation
import DeviceKit

extension FunctionalityPresenter {
  struct State {
    var currentAssessment: (assessment: Assessment, isRunning: Bool) = (.cpu, false)
    var isAssessmentPassed = false
    var isTouchscreenPresented = false
    var isCameraPresented = false
    var isDeadpixelPresented = false
    var isSpecificationPresented = false
    var isSerialRunning = false
    var isConfirmSerial = false
    var allAssessments: [Assessment] = Assessment.allCases
    var passedAssessments: [Assessment: Bool] = [:] {
      didSet {
//        UserDefaults.standard.set(passedAssessments, forKey: "passed_assessments")
      }
    }
    var deviceStatuses: [Status] = []
    var deviceStatus: Status {
      .init(.phone, value: Device.current.safeDescription)
    }
    
    var toastContents: (finished: String, testing: String) {
      let assessment = currentAssessment.assessment
      return (assessment.finishedMessage, assessment.testingMessage)
    }
  }
  
  enum Action {
    case loadStatus
    case start(assessment: Assessment)
    case confirmSerial
    case runSerial
    case terminateSerial
    case shouldShow(assessment: Assessment, isPresented: Bool)
  }
}

extension FunctionalityPresenter {
  struct Status: Equatable {
    let spec: Specs
    let value: String
    var isOther: Bool {
      return spec == .other
    }
    
    init(_ spec: Specs, value: String) {
      self.spec = spec
      self.value = value
    }
    
    enum Specs {
      case phone
      case cpu
      case memory
      case storage
      case battery
      case other
      
      var icon: String {
        switch self {
        case .phone:
          switch true {
          case !Device.current.isWithoutHomeButton && !Device.current.isPad:
            return "iphone.homebutton"
          case Device.current.isPad:
            return "ipad"
          default:
            return "iphone"
          }
        case .cpu:
          return "cpu"
        case .memory:
          return "memorychip"
        case .storage:
          return "internaldrive"
        case .battery:
          return "battery.100"
        case .other:
          return "square.split.2x2.fill"
        }
      }
    }
  }
}

extension FunctionalityPresenter {
  enum GridSide: CaseIterable {
    case right, left
  }
  
  func splitForGrid(side: GridSide) -> [Assessment] {
    var firstColumn: [Assessment] = []
    var secondColumn: [Assessment] = []
    
    state.allAssessments.enumerated().forEach { index, item in
      if index % 2 == 0 {
        firstColumn.append(item)
      } else {
        secondColumn.append(item)
      }
    }
    
    switch side {
    case .right:
      return firstColumn
    case .left:
      return secondColumn
    }
  }
}
