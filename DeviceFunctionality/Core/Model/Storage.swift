//
//  Storage.swift
//  DeviceAssessment
//
//  Created by Uwais Alqadri on 20/3/24.
//

import Foundation

public struct Storage {
  public var readSpeed: String?
  public var writeSpeed: String?
  public var remainingSpace: String?
  public var usedSpace: String?
  public var int32: UInt32?
  public var totalSpace: String?
  public var totalRAM: String?
  
  public init(
    readSpeed: String? = nil,
    writeSpeed: String? = nil,
    remainingSpace: String? = nil,
    usedSpace: String? = nil,
    int32: UInt32? = nil,
    totalSpace: String? = nil,
    totalRAM: String? = nil
  ) {
    self.readSpeed = readSpeed
    self.writeSpeed = writeSpeed
    self.remainingSpace = remainingSpace
    self.usedSpace = usedSpace
    self.int32 = int32
    self.totalSpace = totalSpace
    self.totalRAM = totalRAM
  }
}
