//
//  NetworkReachability.swift
//  DeviceAssessment
//
//  Created by Uwais Alqadri on 6/1/24.
//

import Foundation
import Network
import UIKit

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
