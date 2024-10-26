//
//  BiometricFailedReason.swift
//  DeviceAssessment
//
//  Created by Uwais Alqadri on 20/3/24.
//

import Foundation

public enum BiometricFailedReason: Error {
  case biometricProblemVerifying
  case biometricCancelled
  case biometricEnterPin
  case biometricUnavailable
  case biometricNotSetUp
  case biometricLocked
  case biometricNotConfigured
  case none
  
  public var isBiometricUnavailable: Bool {
    [.biometricNotConfigured, .biometricUnavailable, .biometricNotSetUp, .none].contains(self)
  }
  
  public var isBiometricFailed: Bool {
    [.biometricProblemVerifying, .biometricCancelled, .biometricLocked].contains(self)
  }
}
