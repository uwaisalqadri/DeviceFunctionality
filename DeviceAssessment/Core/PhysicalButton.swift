//
//  PhysicalButton.swift
//  DeviceAssessment
//
//  Created by Uwais Alqadri on 25/12/23.
//

import Foundation
import UIKit

class PhysicalButton: CustomDebugStringConvertible {
  
  static let shared = PhysicalButton()
  
  var action: (() -> Void) = {} {
    didSet {
      if let handler = volumeButtonHandler {
        handler.upBlock = action
        handler.downBlock = action
      }
    }
  }
  var isInUse = false {
    didSet {
      if isInUse && volumeButtonHandler == nil {
        setUp()
        
        if isOn {
          volumeButtonHandler?.start(true)
        }
      }
    }
  }
  
  var isOn = false {
    didSet {
      if isInUse {
        if isOn {
          volumeButtonHandler?.start(true)
        } else {
          volumeButtonHandler?.stop()
        }
      }
    }
  }
  var isSetUp: Bool { return (volumeButtonHandler != nil) }
  
  private var volumeButtonHandler: JPSVolumeButtonHandler?
  static private let minimumTapInterval = 0.3
  private var previousButtonTap = Date()
  
  var debugDescription: String {
    return "PhysicalButton(isInUse: \(isInUse), isOn: \(isOn))"
  }
  
  private init() {
    NotificationCenter.default.addObserver(self, selector: #selector(PhysicalButton.appEnteredBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(PhysicalButton.appEnteringForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
  }
  
  @objc func appEnteredBackground() {
    tearDown()
  }
  
  @objc func appEnteringForeground() {
    if isInUse {
      setUp()
      
      if isOn {
        volumeButtonHandler?.start(true)
      }
    }
  }
  
  private func setUp() {
    volumeButtonHandler = JPSVolumeButtonHandler(up: {
      let rightNow = Date()
      let elapsedTime = rightNow.timeIntervalSince(self.previousButtonTap)
      if elapsedTime >= PhysicalButton.minimumTapInterval {
        self.action()
        self.previousButtonTap = rightNow
      }
    }, downBlock: {
      let rightNow = Date()
      let elapsedTime = rightNow.timeIntervalSince(self.previousButtonTap)
      if elapsedTime >= PhysicalButton.minimumTapInterval {
        self.action()
        self.previousButtonTap = rightNow
      }
    })
  }
  
  func tearDown() {
    if let handler = volumeButtonHandler {
      handler.stop()
      volumeButtonHandler = nil
    }
  }
  
}
