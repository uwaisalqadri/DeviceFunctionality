//
//  PermissionFailed.swift
//  DeviceAssessment
//
//  Created by Uwais Alqadri on 20/3/24.
//

import Foundation

public enum PermissionFailed: Error {
  case gpsNotPermitted
  case bluetoothNotPermitted
  case microphoneNotPermitted
}

