//
//  Notifications.swift
//  DeviceFunctionality
//
//  Created by Uwais Alqadri on 8/9/24.
//

import Foundation

struct Notifications {
  static let didTouchScreenPassed = NSNotification.Name("didTouchScreenPassed")
  static let didDeadpixelPassed = NSNotification.Name(rawValue: "didDeadpixelPassed")
  static let didCameraPassed = NSNotification.Name(rawValue: "didCameraPassed")
}

extension NSNotification.Name {
  func post(with object: Any? = nil) {
    NotificationCenter.default.post(name: self, object: object)
  }
}
