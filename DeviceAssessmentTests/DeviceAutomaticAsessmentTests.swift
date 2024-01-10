//
//  DeviceAutomaticAsessmentTests.swift
//  DeviceAsessmentTests
//
//  Created by Uwais Alqadri on 14/12/23.
//

import XCTest
import Foundation
@testable import DeviceAssessment
import CoreMotion
import CoreTelephony

/**
 * @class DeviceAutomaticAsessmentTests
 * DeviceAutomaticAsessmentTests is a concrete subclass of XCTestCase that act as the test class of Device Assessment Check,
 * start testing using your device and hit run
 */
final class DeviceAutomaticAsessmentTests: XCTestCase {
    
  private var assessmentTester: AssessmentTester!
  
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
    assessmentTester = AssessmentTester(driver: DeviceInfoAssessment())
    debugPrint("This Device has GB of: \((assessmentTester.driver.assessments[.storage] as? String).orDefault)")
    XCTAssertTrue(assessmentTester.driver.hasAssessmentPassed[.storage].orFalse)
  }
  
  func testGetCPUInformation() {
    assessmentTester = AssessmentTester(driver: DeviceInfoAssessment())
    debugPrint("This Device has CPU with following information: \((assessmentTester.driver.assessments[.cpu] as? String).orDefault)")
    XCTAssertTrue(assessmentTester.driver.hasAssessmentPassed[.cpu].orFalse)
  }
  
  func testCheckBatteryStatus() {
    assessmentTester = AssessmentTester(driver: PowerAssessment())
    debugPrint("This Device has Battery Status information: \((assessmentTester.driver.assessments[.batteryStatus] as? String).orDefault)")
    XCTAssertTrue(assessmentTester.driver.hasAssessmentPassed[.batteryStatus].orFalse)
  }
  
  func testCheckDeviceIsNotJailBroken() {
    assessmentTester = AssessmentTester(driver: DeviceInfoAssessment())
    XCTAssertTrue(assessmentTester.driver.hasAssessmentPassed[.notJailbroken].orFalse)
  }
  
  func testCheckSIMCard() {
    assessmentTester = AssessmentTester(driver: ConnectivityAssessment())
    debugPrint("SIM \((assessmentTester.driver.assessments[.sim] as? Bool).orFalse)")
    XCTAssertTrue(assessmentTester.driver.hasAssessmentPassed[.sim].orFalse)
  }
  
  func testCheckConnectivity() {
    let exp = expectation(description: "wait for network status")
    
    assessmentTester = AssessmentTester(driver: ConnectivityAssessment())
    assessmentTester.driver.startAssessment(for: .wifi) { [weak self] in
      self?.debugPrint("WIFI \((self?.assessmentTester.driver.assessments[.wifi] as? Bool).orFalse)")
      exp.fulfill()
    }
    
    waitForExpectations(timeout: 2)
    
    XCTAssertTrue(self.assessmentTester.driver.hasAssessmentPassed[.wifi].orFalse)
  }
  
  func testCheckVolumeDownButton() {
    let exp = expectation(description: "wait for click volume down")
    
    assessmentTester = AssessmentTester(driver: PhysicalActivityAssessment())
    assessmentTester.driver.startAssessment(for: .volumeDownButton) { [weak self] in
      if let self = self, self.assessmentTester.driver.hasAssessmentPassed[.volumeDownButton].orFalse {
        exp.fulfill()
      }
    }
    
    wait(for: [exp], timeout: 100)
    
    XCTAssertTrue(self.assessmentTester.driver.hasAssessmentPassed[.volumeDownButton].orFalse)
  }
  
  func testCheckVolumeUpButton() {
    let exp = expectation(description: "wait for click volume up")
    
    assessmentTester = AssessmentTester(driver: PhysicalActivityAssessment())
    assessmentTester.driver.startAssessment(for: .volumeUpButton) { [weak self] in
      if let self = self, self.assessmentTester.driver.hasAssessmentPassed[.volumeUpButton].orFalse {
        exp.fulfill()
      }
    }
    
    wait(for: [exp], timeout: 100)
    
    XCTAssertTrue(self.assessmentTester.driver.hasAssessmentPassed[.volumeUpButton].orFalse)
  }
  
  func testCheckVolumeMuteSwitch() {
    let exp = expectation(description: "wait for click mute switch")
    
    assessmentTester = AssessmentTester(driver: PhysicalActivityAssessment())
    assessmentTester.driver.startAssessment(for: .muteSwitch) { [weak self] in
      if let self = self, self.assessmentTester.driver.hasAssessmentPassed[.muteSwitch].orFalse {
        exp.fulfill()
      }
    }
    
    wait(for: [exp], timeout: 5)
    
    XCTAssertTrue(self.assessmentTester.driver.hasAssessmentPassed[.muteSwitch].orFalse)
  }
  
  func testCheckAccelerometer() {
    assessmentTester = AssessmentTester(driver: PhysicalActivityAssessment())
    XCTAssertTrue(assessmentTester.driver.hasAssessmentPassed[.accelerometer].orFalse)
  }
  
  private func debugPrint(_ message: String) {
    print("TEST DEBUG: ", message)
  }
}
