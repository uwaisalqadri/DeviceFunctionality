//
//  SpecificationView.swift
//  DeviceFunctionality
//
//  Created by Uwais Alqadri on 27/10/24.
//

import Foundation
import SwiftUI
import DeviceKit
import CoreMotion

struct SpecificationView: View {
  var models: [Model] {
    getDeviceModels()
  }
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Text("Information")
          .fontWeight(.bold)
          .frame(maxWidth: .infinity, alignment: .leading)
        Divider()
        Text("Specification")
          .fontWeight(.bold)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
      .padding()
      .background(Color.gray.opacity(0.1))
      .clipShape(RoundedRectangle(cornerRadius: 14))
      .frame(height: 50)
      
      List(models) { model in
        HStack {
          Text(model.title)
            .frame(maxWidth: .infinity, alignment: .leading)
          Text(model.value)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 4)
      }
      .listStyle(PlainListStyle())
    }
    .padding(16)
    .navigationTitle(Device.current.safeDescription)
  }
}

extension SpecificationView {
  struct Model: Identifiable {
    let id = UUID()
    let title: String
    let value: String
  }
  
  func getDeviceModels() -> [Model] {
    let screenSize = UIScreen.main.bounds.size
    let displayType = UIScreen.main.traitCollection.displayGamut == .P3 ? "OLED" : "LCD"
    let resolution = "\(UIScreen.main.nativeBounds.size.width)x\(UIScreen.main.nativeBounds.size.height) @ \(UIScreen.main.scale) PPI"
    
    return [
      .init(title: "Model", value: "\(UIDevice.current.model) (\(getDeviceIdentifier()))"),
      .init(title: "Model number", value: "\(modelIdentifier())"),
      .init(title: "Size", value: "\(formatScreenSize(screenSize))"),
      .init(title: "Weight", value: "135 g"),  // Placeholder
      .init(title: "iOS Ver.", value: UIDevice.current.systemVersion),
      .init(title: "Display", value: displayType),
      .init(title: "Screen size", value: "\(screenSize.width)x\(screenSize.height)"),
      .init(title: "Resolution", value: resolution),
      .init(title: "Multitouch", value: "Supported"),
      .init(title: "3D Touch", value: check3DTouchSupport()),
//      .init(title: "Camera", value: "Dual 12 MP, Rear and Ultra Wide"),  // Placeholder
//      .init(title: "Rear Camera", value: "12 MP, f/1.6, 26mm"),  // Static placeholder
//      .init(title: "Telephoto Camera", value: "N/A"),  // Static placeholder
//      .init(title: "Ultra Wide Camera", value: "12 MP, f/2.4, 120°, 13mm"),  // Static placeholder
//      .init(title: "Back camera recording quality", value: "4K (24/30/60FPS), 1080p (30/60/120/240FPS)"),  // Static placeholder
//      .init(title: "Front Camera", value: "12 MP, f/2.2, 23mm"),  // Static placeholder
//      .init(title: "Front camera recording quality", value: "4K (24/30/60FPS), 1080p (30/60/120FPS)"),  // Static placeholder
      .init(title: "Accelerometer", value: checkSensorAvailability(.accelerometer)),
      .init(title: "Gyroscope", value: checkSensorAvailability(.gyroscope)),
      .init(title: "Proximity Sensor", value: "Supported"),
      .init(title: "Light Sensor", value: "Supported"),
      .init(title: "Magnetometer", value: checkSensorAvailability(.magnetometer)),
      .init(title: "Barometer", value: "\(CMAltimeter.isRelativeAltitudeAvailable() ? "Supported" : "Not Supported")")
    ]
  }
  
  // MARK: - Helper Methods
  
  private func getDeviceIdentifier() -> String {
    return String(UIDevice.current.identifierForVendor?.uuidString.prefix(5) ?? "-")
  }
  
  private func formatScreenSize(_ size: CGSize) -> String {
    return "\(size.width)x\(size.height) mm"
  }
  
  private func check3DTouchSupport() -> String {
    return UIScreen.main.traitCollection.forceTouchCapability == .available ? "Supported" : "Not supported"
  }
  
  enum SensorType {
    case accelerometer, gyroscope, magnetometer
  }
  
  private func checkSensorAvailability(_ type: SensorType) -> String {
    let motionManager = CMMotionManager()
    
    switch type {
    case .accelerometer:
      return motionManager.isAccelerometerAvailable ? "Supported" : "Not Supported"
    case .gyroscope:
      return motionManager.isGyroAvailable ? "Supported" : "Not Supported"
    case .magnetometer:
      return motionManager.isMagnetometerAvailable ? "Supported" : "Not Supported"
    }
  }
  
  func modelIdentifier() -> String {
    var systemInfo = utsname()
    uname(&systemInfo)
    return withUnsafePointer(to: &systemInfo.machine) {
      $0.withMemoryRebound(to: CChar.self, capacity: 1) {
        String(validatingUTF8: $0) ?? "Unknown"
      }
    }
  }
}
