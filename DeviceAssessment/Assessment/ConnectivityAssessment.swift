//
//  ConnectivityAssessment.swift
//  DeviceAssessment
//
//  Created by Uwais Alqadri on 15/12/23.
//

import Foundation
import Network
import UIKit

class ConnectivityAssessment: AssessmentDriver {
  private let reachability: NetworkReachability
  
  init(reachability: NetworkReachability) {
    self.reachability = reachability
  }
    
  var hasAssessmentPassed: [Assessment: Bool] {
    var results: [Assessment: Bool] =  [:]
    
    if let assessment = assessments[.sim] as? Bool {
      results[.sim] = assessment
    } else {
      results[.sim] = false
    }
    
    if let assessment = assessments[.wifi] as? Bool {
      results[.wifi] = assessment
    } else {
      results[.wifi] = false
    }
    
    return results
  }
  
  lazy var assessments: [Assessment: Any] = [.sim: isSIMAvailable]
  
  private var isSIMAvailable: Bool {
    let isCapableToCall = UIApplication.shared.canOpenURL(URL(string: "tel://")!)
    let isCapableToSMS = UIApplication.shared.canOpenURL(URL(string: "sms:")!)
    return isCapableToCall || isCapableToSMS
  }
  
  func startAssessment(completion: (() -> Void)? = nil) {
    reachability.updateConnectivityHandler = { [weak self] status in
      guard let self = self else { return }
      self.assessments[.wifi] = status == .satisfied
      
      completion?()
    }
  }
}

class NetworkReachability {
  
  var pathMonitor: NWPathMonitor!
  var path: NWPath?
  
  var updateConnectivityHandler: ((NWPath.Status) -> Void)?
  
  lazy var pathUpdateHandler: ((NWPath) -> Void) = { path in
    self.path = path
    self.updateConnectivityHandler?(path.status)
  }
  
  let backgroudQueue = DispatchQueue.global(qos: .background)
  
  init() {
    pathMonitor = NWPathMonitor()
    pathMonitor.pathUpdateHandler = self.pathUpdateHandler
    pathMonitor.start(queue: backgroudQueue)
  }
  
  func isNetworkAvailable() -> Bool {
    if let path = self.path {
      return path.status == .satisfied
    }
    return false
  }
}
