//
//  DeviceAutomaticAsessmentTests.swift
//  DeviceAsessmentTests
//
//  Created by Uwais Alqadri on 14/12/23.
//

import XCTest
import Foundation
@testable import DeviceAssessment

/**
 * @class DeviceAutomaticAsessmentTests
 * DeviceAutomaticAsessmentTests is a concrete subclass of XCTestCase that act as the test class of Device Assessment Check,
 * start testing using your device and hit run
 */
final class DeviceAutomaticAsessmentTests: XCTestCase {
    
  private var deviceTester: AssessmentTester!
  
  func testGetDeviceInformation() {
       
    let brand = "Apple"
    let marketingName = UIDevice.current.name
    let model = UIDevice.current.model
    
    debugPrint(brand)
    debugPrint(marketingName)
    debugPrint(model)
    
    XCTAssertFalse(brand.isEmpty)
    XCTAssertFalse(marketingName.isEmpty)
    XCTAssertFalse(model.isEmpty)
  }
  
  func testGetDeviceStorage() {
    deviceTester = AssessmentTester(driver: DeviceInfoAssessment(processInfo: ProcessInfo.processInfo, device: UIDevice.current))
    debugPrint("This Device has GB of: \((deviceTester.driver.assessments[.storage] as? String).orDefault)")
    XCTAssertTrue(deviceTester.driver.hasAssessmentPassed[.storage].orFalse)
  }
  
  func testGetCPUInformation() {
    deviceTester = AssessmentTester(driver: DeviceInfoAssessment(processInfo: ProcessInfo.processInfo, device: UIDevice.current))
    debugPrint("This Device has CPU with following information: \((deviceTester.driver.assessments[.cpu] as? String).orDefault)")
    XCTAssertTrue(deviceTester.driver.hasAssessmentPassed[.cpu].orFalse)
  }
  
  func testCheckBatteryStatus() {
    deviceTester = AssessmentTester(driver: PowerAssessment(powerInfo: EEPowerInformation()))
    debugPrint("This Device has Battery Status information: \((deviceTester.driver.assessments[.batteryStatus] as? String).orDefault)")
    XCTAssertTrue(deviceTester.driver.hasAssessmentPassed[.batteryStatus].orFalse)
  }
  
  func testCheckDeviceIsNotJailBroken() {
    deviceTester = AssessmentTester(driver: DeviceInfoAssessment(processInfo: ProcessInfo.processInfo, device: UIDevice.current))
    XCTAssertTrue(deviceTester.driver.hasAssessmentPassed[.notJailbroken].orFalse)
  }
  
  func testCheckSIMCard() {
    deviceTester = AssessmentTester(driver: ConnectivityAssessment(reachability: NetworkReachability()))
    debugPrint("SIM \((deviceTester.driver.assessments[.sim] as? Bool).orFalse)")
    XCTAssertTrue(deviceTester.driver.hasAssessmentPassed[.sim].orFalse)
  }
  
  func testCheckConnectivity() {
    let exp = expectation(description: "wait for network status")
    
    deviceTester = AssessmentTester(driver: ConnectivityAssessment(reachability: NetworkReachability()))
    deviceTester.driver.startAssessment { [weak self] in
      self?.debugPrint("WIFI \((self?.deviceTester.driver.assessments[.wifi] as? Bool).orFalse)")
      exp.fulfill()
    }
    
    waitForExpectations(timeout: 2)
    
    XCTAssertTrue(self.deviceTester.driver.hasAssessmentPassed[.wifi].orFalse)
  }
  
  private func debugPrint(_ message: String) {
    print("TEST DEBUG: ", message)
  }
}
