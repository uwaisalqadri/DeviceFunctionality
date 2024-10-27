//
//  Assessment.swift
//  DeviceAssessment
//
//  Created by Uwais Alqadri on 20/3/24.
//

import Foundation

public enum Assessment: String, CaseIterable, Codable {
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
  case multitouch
  case sim
  case wifi
  case biometric
  case accelerometer
  case barometer
  case bluetooth
  case gps
  case compass
  case homeButton
  case mainSpeaker
  case earSpeaker
  case proximity
  case deadpixel
  case rotation
  case microphone

  public static var allCases: [Assessment] {
    let allCases: [Assessment] = [
      .cpu,
      .storage,
      .batteryStatus,
      .rootStatus,
      .silentSwitch,
      .volumeUp,
      .volumeDown,
      .powerButton,
      .vibration,
      .camera,
      .touchscreen,
      .sim,
      .wifi,
      .biometric,
      .accelerometer,
      .bluetooth,
      .gps,
//      .homeButton,
      .mainSpeaker,
      .earSpeaker,
      .proximity,
      .deadpixel,
      .rotation,
      .microphone,
    ]

    return allCases
  }
}
