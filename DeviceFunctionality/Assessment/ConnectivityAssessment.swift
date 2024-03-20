//
//  ConnectivityAssessment.swift
//  DeviceAssessment
//
//  Created by Uwais Alqadri on 15/12/23.
//

import CoreBluetooth
import CoreLocation
import CoreTelephony
import Foundation
import Network
import SystemConfiguration.CaptiveNetwork
import UIKit

public class ConnectivityAssessment: NSObject, AssessmentDriver {
  private var wifiPathMonitor: NWPathMonitor?
  private var cellularPathMonitor: NWPathMonitor?
  private let telephonyInfo = CTTelephonyNetworkInfo()
  private let locationManager = CLLocationManager()
  private var centralManager: CBCentralManager?
  
  private var onCentralManagerUpdated: ((_ central: CBCentralManager) -> Void)?
  private var onLocationUpdated: ((Bool) -> Void)?
  private let wifiConnectionQueue = DispatchQueue(label: "wifi.connection.queue")
  private let cellularConnectionQueue = DispatchQueue(label: "cellular.connection.queue")
  
  public override init() {
    super.init()
  }
  
  public var hasAssessmentPassed: [Assessment: Bool] {
    var results: [Assessment: Bool] = [:]
    
    let assessmentTypes: [Assessment] = [.wifi, .sim, .bluetooth, .gps]
    
    for type in assessmentTypes {
      results[type] = assessments[type] as? Bool ?? false
    }
    
    return results
  }
  
  public var assessments: [Assessment: Any] = [
    .wifi: false,
    .sim: false,
    .bluetooth: false,
    .gps: false
  ]
  
  public func startAssessment(for type: Assessment, completion: (() -> Void)? = nil) {
    switch type {
    case .sim:
      cellularPathMonitor = NWPathMonitor()
      cellularPathMonitor?.start(queue: cellularConnectionQueue)
      
      cellularPathMonitor?.pathUpdateHandler = { [weak self] path in
        guard path.status == .satisfied && path.usesInterfaceType(.cellular) else { return }
        
        self?.assessments[.sim] = true
        completion?()
        self?.cellularPathMonitor?.cancel()
      }
      
    case .wifi:
      wifiPathMonitor = NWPathMonitor()
      wifiPathMonitor?.start(queue: wifiConnectionQueue)
      
      wifiPathMonitor?.pathUpdateHandler = { [weak self] path in
        guard path.status == .satisfied && path.usesInterfaceType(.wifi) else { return }
        
        self?.assessments[.wifi] = true
        completion?()
        self?.wifiPathMonitor?.cancel()
      }
      
    case .bluetooth:
      centralManager = CBCentralManager()
      centralManager?.delegate = self
      onCentralManagerUpdated = { [weak self] central in
        switch central.state {
        case .poweredOn:
          self?.assessments[.bluetooth] = true
          completion?()
        case .unsupported, .unknown:
          self?.assessments[.bluetooth] = false
          completion?()
        default:
          self?.assessments[.bluetooth] = PermissionFailed.bluetoothNotPermitted
          completion?()
        }
      }
      
    case .gps:
      locationManager.delegate = self
      
      switch CLLocationManager.authorizationStatus() {
      case .authorizedWhenInUse, .authorizedAlways:
        self.assessments[.gps] = true
        completion?()
      case .denied:
        self.assessments[.gps] = PermissionFailed.gpsNotPermitted
        completion?()
      default:
        locationManager.requestWhenInUseAuthorization()
        onLocationUpdated = { [weak self] isLocated in
          self?.assessments[.gps] = isLocated
          completion?()
        }
      }
      
    default:
      break
    }
  }
  
  public func stopAssessment(for type: Assessment) {
    switch type {
    case .wifi:
      wifiPathMonitor?.cancel()
    case .sim:
      cellularPathMonitor?.cancel()
    default:
      break
    }
  }
}

extension ConnectivityAssessment: CBCentralManagerDelegate, CLLocationManagerDelegate {
  public func centralManagerDidUpdateState(_ central: CBCentralManager) {
    onCentralManagerUpdated?(central)
  }
  
  public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    switch CLLocationManager.authorizationStatus() {
    case .authorizedAlways, .authorizedWhenInUse:
      onLocationUpdated?(true)
    default:
      onLocationUpdated?(false)
    }
  }
 }
