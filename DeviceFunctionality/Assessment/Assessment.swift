//
//  Assessment.swift
//  DeviceAssessment
//
//  Created by Uwais Alqadri on 20/3/24.
//

import Foundation

public enum Assessment: CaseIterable, Codable {
  case cpu
  case storage
  case batteryStatus
  case rootStatus
  case silentSwitch
  case volumeUp
  case volumeDown
  case powerButton
  case vibration
  case camera
  case touchscreen
  case sim
  case wifi
  case biometric
  case accelerometer
  case bluetooth
  case gps
  case homeButton
  case mainSpeaker
  case earSpeaker
  case proximity
  case deadpixel
  case rotation
  case microphone
}
