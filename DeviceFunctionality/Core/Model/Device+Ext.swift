//
//  Device+Ext.swift
//  DeviceAssessment
//
//  Created by Uwais Alqadri on 20/3/24.
//

import DeviceKit
import Foundation

extension Device {
  public var isWithoutHomeButton: Bool {
    return isOneOf(Device.allDevicesWithoutHomeButton) || isOneOf(Device.allDevicesWithoutHomeButton.map(Device.simulator))
  }
  
  // swiftlint:disable line_length
  public static var allDevicesWithoutHomeButton: [Device] {
    return [.iPhoneX, .iPhoneXS, .iPhoneXSMax, .iPhoneXR, .iPhone11, .iPhone11Pro, .iPhone11ProMax, .iPhone12, .iPhone12Mini, .iPhone12Pro, .iPhone12ProMax, .iPhone13, .iPhone13Mini, .iPhone13Pro, .iPhone13ProMax, .iPhone14, .iPhone14Plus, .iPhone14Pro, .iPhone14ProMax, .iPhone15, .iPhone15Plus, .iPhone15Pro, .iPhone15ProMax, .iPadPro11Inch3, .iPadPro12Inch3, .iPadPro12Inch4]
  }
}

public enum AppInfo {
  public static var applicationVersion: String {
    Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
  }
}
