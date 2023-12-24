//
//  Optional+Default.swift
//  DeviceAssessment
//
//  Created by Uwais Alqadri on 24/12/23.
//

import Foundation

extension Optional where Wrapped == String {
  var orDefault: String {
    self ?? ""
  }
}

extension Optional where Wrapped == Int {
  var orDefault: Int {
    self ?? 0
  }
}

extension Optional where Wrapped == Double {
  var orDefault: Double {
    self ?? 0.0
  }
}

extension Optional where Wrapped == Float {
  var orDefault: Float {
    self ?? 0.0
  }
}

extension Optional where Wrapped == Bool {
  var orFalse: Bool {
    self ?? false
  }
}
