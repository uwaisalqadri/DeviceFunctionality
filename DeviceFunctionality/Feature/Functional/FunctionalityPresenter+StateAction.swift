//
//  FunctionalityPresenter+StateAction.swift
//  DeviceFunctionality
//
//  Created by Uwais Alqadri on 03/09/24.
//

import Foundation

extension FunctionalityPresenter {
  struct State {
    var currentAssessment: (assessment: Assessment, isRunning: Bool) = (.cpu, false)
    var isAssessmentPassed = false
    var isTouchscreenPresented = false
    var isCameraPresented = false
    var isDeadpixelPresented = false
    var isSerialRunning = false
    var isConfirmSerial = false
    var allAssessments: [Assessment] = Assessment.allCases
    var passedAssessments: [Assessment: Bool] = [:]
    
    var toastContents: (finished: String, testing: String) {
      let assessment = currentAssessment.assessment
      return (assessment.finishedMessage, assessment.testingMessage)
    }
  }
  
  enum Action {
    case start(assessment: Assessment)
    case confirmSerial
    case runSerial
    case shouldShow(assessment: Assessment, isPresented: Bool)
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
