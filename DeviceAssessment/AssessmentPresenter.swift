//
//  AssessmentPresenter.swift
//  DeviceAssessment
//
//  Created by Uwais Alqadri on 6/1/24.
//

import SwiftUI
import CoreMotion
import CoreTelephony

class AssessmentPresenter: ObservableObject {
  
  @Published var isVolumeUpClicked = false
  @Published var isVolumeDownClicked = false
  @Published var isMuteClicked = false
  @Published var wifiSSID: String = ""
  @Published var batteryInformation = PowerAssessment.BatteryStatus(batteryMaxCapacity: 0, batteryHealth: 0.0, batteryCycleCount: 0)
  
  var isAccelerometerAvailable: Bool {
    let assessmentTester = AssessmentTester(driver: PhysicalActivityAssessment())
    return assessmentTester.driver.hasAssessmentPassed[.accelerometer].orFalse
  }
  
  var isNotJailbroken: Bool {
    let assessmentTester = AssessmentTester(driver: DeviceInfoAssessment())
    return assessmentTester.driver.hasAssessmentPassed[.notJailbroken].orFalse
  }
  
  var carrierName: String {
    let assessmentTester = AssessmentTester(driver: ConnectivityAssessment())
    return (assessmentTester.driver.assessments[.sim] as? String) ?? ""
  }
  
  func getDeviceStorage() -> String {
    let assessmentTester = AssessmentTester(driver: DeviceInfoAssessment())
    return (assessmentTester.driver.assessments[.storage] as? DeviceInfoAssessment.Storage)?.totalDiskSpaceGB ?? ""
  }
  
  func getDeviceRAM() -> String {
    let assessmentTester = AssessmentTester(driver: DeviceInfoAssessment())
    return (assessmentTester.driver.assessments[.storage] as? DeviceInfoAssessment.Storage)?.totalRAMGB ?? ""
  }
  
  func getCPUInformation() -> String {
    let assessmentTester = AssessmentTester(driver: DeviceInfoAssessment())
    return (assessmentTester.driver.assessments[.cpu] as? DeviceInfoAssessment.CPUInformation)?.name ?? ""
  }
  
  func startObservingMuteSwitch() {
    let assessmentTester = AssessmentTester(driver: PhysicalActivityAssessment())
    assessmentTester.driver.startAssessment(for: .muteSwitch) { [weak self] in
      guard let self = self else { return }
      self.isMuteClicked = assessmentTester.driver.hasAssessmentPassed[.muteSwitch] ?? false
    }
  }
  
  func startObservingVolumeUpButton() {
    let assessmentTester = AssessmentTester(driver: PhysicalActivityAssessment())
    assessmentTester.driver.startAssessment(for: .volumeUpButton) { [weak self] in
      guard let self = self else { return }
      self.isVolumeUpClicked = assessmentTester.driver.hasAssessmentPassed[.volumeUpButton] ?? false
    }
  }
  
  func startObservingVolumeDownButton() {
    let assessmentTester = AssessmentTester(driver: PhysicalActivityAssessment())
    assessmentTester.driver.startAssessment(for: .volumeDownButton) { [weak self] in
      guard let self = self else { return }
      self.isVolumeDownClicked = assessmentTester.driver.hasAssessmentPassed[.volumeDownButton] ?? false
    }
  }
  
  func startObservingBatteryStatus() {
    let assessment = PowerAssessment()
    let assessmentTester = AssessmentTester(driver: assessment)
    
    assessment.powerInformationUpdated = { [weak self] in
      guard let self = self, let batteryStatus = assessmentTester.driver.assessments[.batteryStatus] as? PowerAssessment.BatteryStatus else { return }
      self.batteryInformation = batteryStatus
    }
  }
  
  func startObservingConnectivity() {
    let assessmentTester = AssessmentTester(driver: ConnectivityAssessment())
    assessmentTester.driver.startAssessment(for: .wifi) { [weak self] in
      guard let self = self,
            let wifi = assessmentTester.driver.assessments[.wifi] as? ConnectivityAssessment.Wifi
      else { return }
      self.wifiSSID = wifi.connectedSSID
    }
  }
}
