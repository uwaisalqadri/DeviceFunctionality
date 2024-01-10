//
//  ContentView.swift
//  SpecAsessment
//
//  Created by Uwais Alqadri on 13/12/23.
//

import SwiftUI
import DeviceKit
import CoreMotion

struct AssessmentView: View {
  
  @ObservedObject var presenter: AssessmentPresenter
  
  var body: some View {
    VStack {
      List {
        Section(header: (
          Text("Current Device:")
            .font(.system(size: 14)) +
          Text("\n\(Device.current.description)")
            .font(.system(size: 24, weight: .bold))
        ).multilineTextAlignment(.leading).padding(.vertical, 10)) {
          
          AssessmentRow(iconName: "gear", title: "CPU", value: presenter.getCPUInformation())
          AssessmentRow(iconName: "lock", title: "Jail Broken", value: (!presenter.isNotJailbroken).toYesNo())
          AssessmentRow(iconName: "cube.box", title: "RAM", value: presenter.getDeviceRAM())
          AssessmentRow(iconName: "folder", title: "Storage", value: presenter.getDeviceStorage())
          AssessmentRow(iconName: "battery.100", title: "Battery Status", value: "\(presenter.batteryInformation.batteryMaxCapacity)")
//          AssessmentRow(iconName: "faceid", title: "Biometric", value: )
          AssessmentRow(iconName: "globe", title: "Accelerometer", value: presenter.isAccelerometerAvailable.toYesNo())
          AssessmentRow(iconName: "bell.slash", title: "Silent Mode", value: presenter.isMuteClicked.toOnOff())
          AssessmentRow(iconName: "speaker.3.fill", title: "Volume Up is Clicked", value: presenter.isVolumeUpClicked.toYesNo())
          AssessmentRow(iconName: "speaker.1.fill", title: "Volume Down is Clicked", value: presenter.isVolumeDownClicked.toYesNo())
//          AssessmentRow(iconName: "globe", title: "Power Button")
//          AssessmentRow(iconName: "waveform.path", title: "Vibration")
//          AssessmentRow(iconName: "camera", title: "Camera")
          AssessmentRow(iconName: "phone", title: "SIM", value: presenter.carrierName)
          AssessmentRow(iconName: "wifi", title: "WIFI", value: presenter.wifiSSID)
          
        }.headerProminence(.increased)
      }
    }.onAppear {
      presenter.startObservingConnectivity()
      presenter.startObservingBatteryStatus()
      presenter.startObservingVolumeUpButton()
      presenter.startObservingVolumeDownButton()
      presenter.startObservingMuteSwitch()
    }
  }
}

struct AssessmentRow: View {
  let iconName: String
  let title: String
  let value: String
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Image(systemName: iconName)
        .imageScale(.large)
        .foregroundColor(.accentColor)
      
      Text(title + ": ") +
      Text(value)
        .bold()
    }
  }
}

struct AssessmentView_Previews: PreviewProvider {
  static var previews: some View {
    AssessmentView(presenter: AssessmentPresenter())
  }
}
