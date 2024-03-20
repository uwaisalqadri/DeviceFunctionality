//
//  Battery.swift
//  DeviceAssessment
//
//  Created by Uwais Alqadri on 20/3/24.
//

public struct Battery {
  public var voltage: String?
  public var technology: String?
  public var replacementStatus: String?
  public var status: String?
  public var health: String?
  public var temperature: String?
  
  public init(voltage: String? = nil, technology: String? = nil, replacementStatus: String? = nil, status: String? = nil, health: String? = nil, temperature: String? = nil) {
    self.voltage = voltage
    self.technology = technology
    self.replacementStatus = replacementStatus
    self.status = status
    self.health = health
    self.temperature = temperature
  }
}
