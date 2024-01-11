//
//  BiometricAuthentication.swift
//  DeviceAssessment
//
//  Created by Uwais Alqadri on 11/1/24.
//

import Foundation
import LocalAuthentication

enum BiometricType {
  case none
  case touchID
  case faceID
}

enum BiometricFailedReason {
  case biometricProblemVerifying
  case biometricCancelled
  case biometricEnterPin
  case biometricUnavailable
  case biometricNotSetUp
  case biometricLocked
  case biometricNotConfigured
  case none
}

class BiometricIDAuth {
  let context = LAContext()
  var loginReason = "Checking Biometric"
  func biometricType() -> BiometricType {
    let _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    switch context.biometryType {
    case .none:
      return .none
    case .touchID:
      loginReason = "Touch ID"
      return .touchID
    case .faceID:
      loginReason = "Face ID"
      return .faceID
    default:
      return .none
    }
  }
  
  func canEvaluatePolicy() -> Bool {
    return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
  }
  
  func authenticateUser(completion: @escaping (BiometricFailedReason, Error?) -> Void) {
    context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: loginReason) { (success, evaluateError) in
      DispatchQueue.main.async {
        if success {
          completion(.none, nil)
        } else {
          var reason: BiometricFailedReason
          switch evaluateError {
          case LAError.authenticationFailed?:
            reason = .biometricProblemVerifying
          case LAError.userCancel?:
            reason = .biometricCancelled
          case LAError.userFallback?:
            reason = .biometricEnterPin
          case LAError.biometryNotAvailable?:
            reason = .biometricUnavailable
          case LAError.biometryNotEnrolled?:
            reason = .biometricNotSetUp
          case LAError.biometryLockout?:
            reason = .biometricLocked
          default:
            reason = .biometricNotConfigured
          }
          completion(reason, evaluateError)
        }
      }
    }
  }
}
