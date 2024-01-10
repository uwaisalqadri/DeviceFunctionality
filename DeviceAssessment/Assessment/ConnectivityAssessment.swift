//
//  ConnectivityAssessment.swift
//  DeviceAssessment
//
//  Created by Uwais Alqadri on 15/12/23.
//

import Foundation
import Network
import UIKit
import CoreTelephony
import SystemConfiguration.CaptiveNetwork
import CoreLocation

class ConnectivityAssessment: NSObject, AssessmentDriver {
  private var reachability = NetworkReachability()
  private var telephonyInfo = CTTelephonyNetworkInfo()
  
  var locationManager = CLLocationManager()
  
  override init() {
    super.init()
    locationManager.delegate = self
  }
  
  var hasAssessmentPassed: [Assessment: Bool] {
    var results: [Assessment: Bool] =  [:]
    
    if let assessment = assessments[.sim] as? String {
      results[.sim] = !assessment.isEmpty || isCapableToCall
    } else {
      results[.sim] = false
    }
    
    if let assessment = assessments[.wifi] as? Wifi {
      results[.wifi] = assessment.isConnected
    } else {
      results[.wifi] = false
    }
    
    return results
  }
  
  lazy var assessments: [Assessment: Any] = [.sim: carrierName]
  
  func startAssessment(for type: Assessment, completion: (() -> Void)? = nil) {
    if type == .wifi {
      locationManager.requestWhenInUseAuthorization()
      if locationManager.authorizationStatus == .authorizedWhenInUse {
        updateWifiStatus(.satisfied)
        completion?()
      }
    }
  }
  
}

// MARK: Cellular
extension ConnectivityAssessment {
  private var isCapableToCall: Bool {
    let isCapableToCall = UIApplication.shared.canOpenURL(URL(string: "tel://")!)
    let isCapableToSMS = UIApplication.shared.canOpenURL(URL(string: "sms:")!)
    return isCapableToCall || isCapableToSMS
  }
  
  private var carrierName: String {
    telephonyInfo.subscriberCellularProvider?.carrierName ?? "N/A"
  }
}

// MARK: WIFI
extension ConnectivityAssessment: CLLocationManagerDelegate {
  struct Wifi {
    var connectedSSID: String
    var connectedBSSID: String
    var isConnected: Bool = false
  }
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    switch status {
    case .authorized, .authorizedAlways, .authorizedWhenInUse:
      updateWifiStatus(.satisfied)
    default:
      break
    }
  }
  
  func updateWifiStatus(_ status: NWPath.Status) {
    assessments[.wifi] = Wifi(connectedSSID: self.connectedSSID, connectedBSSID: self.connectedBSSID, isConnected: status == .satisfied)
  }
  
  func fetchSSIDInfo() -> CFDictionary? {
    if let supportedInterfacesArray = CNCopySupportedInterfaces() as? [CFString] {
      for info in supportedInterfacesArray {
        if let dictionary = CNCopyCurrentNetworkInfo(info) {
          return dictionary
        }
      }
    }
    return nil
  }
  
  var connectedSSID: String {
    if let ssidInfo = fetchSSIDInfo() {
      if let ssidInfoString = (ssidInfo as NSDictionary)[kCNNetworkInfoKeySSID] as? String {
        return ssidInfoString
      }
    }
    return ""
  }
  
  var connectedBSSID: String {
    if let ssidInfo = fetchSSIDInfo() {
      if let bssidInfoString = (ssidInfo as NSDictionary)[kCNNetworkInfoKeyBSSID] as? String {
        return bssidInfoString
      }
    }
    return ""
  }
}
