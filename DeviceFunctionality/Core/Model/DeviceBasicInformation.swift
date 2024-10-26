//
//  DeviceBasicInformation.swift
//  DeviceAssessment
//
//  Created by Uwais Alqadri on 20/3/24.
//

import Foundation

public struct DeviceBasicInformation {
  public var marketingName: String
  public var modelName: String
  public var brand: String = "Apple"
  public var variant: String
  public var ram: String
  public var isNotJailBroken: Bool
  
  public init(
    marketingName: String,
    modelName: String,
    variant: String,
    ram: String,
    isNotJailBroken: Bool
  ) {
    self.marketingName = marketingName
    self.modelName = modelName
    self.variant = variant
    self.ram = ram
    self.isNotJailBroken = isNotJailBroken
  }
}
