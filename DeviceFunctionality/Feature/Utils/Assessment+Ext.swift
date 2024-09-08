//
//  Assessment+Ext.swift
//  DeviceFunctionality
//
//  Created by Uwais Alqadri on 25/3/24.
//

import Foundation

extension Assessment {
  var icon: String {
    switch self {
    case .cpu:
      return "📱"
    case .storage:
      return "🫙"
    case .batteryStatus:
      return "🔋"
    case .rootStatus:
      return "🔏"
    case .silentSwitch:
      return "🔕"
    case .volumeUp:
      return "🔊"
    case .volumeDown:
      return "🔈"
    case .powerButton:
      return "📵"
    case .vibration:
      return "🫨"
    case .camera:
      return "📸"
    case .touchscreen:
      return "👆"
    case .sim:
      return "📶"
    case .wifi:
      return "🛜"
    case .biometric:
      return "🪪"
    case .accelerometer:
      return "📏"
    case .bluetooth:
      return "🚹"
    case .gps:
      return "🌐"
    case .homeButton:
      return "🏠"
    case .mainSpeaker:
      return "📻"
    case .earSpeaker:
      return "🎧"
    case .proximity:
      return "⚠️"
    case .deadpixel:
      return "💀"
    case .rotation:
      return "🔄"
    case .microphone:
      return "🎙️"
    }
  }
  
  var title: String {
    switch self {
    case .cpu:
      return "CPU"
    case .storage:
      return "Storage"
    case .batteryStatus:
      return "Battery"
    case .rootStatus:
      return "Jailbreak"
    case .silentSwitch:
      return "Silent Switch"
    case .volumeUp:
      return "Volume Up"
    case .volumeDown:
      return "Volume Down"
    case .powerButton:
      return "Power Button"
    case .vibration:
      return "Vibration"
    case .camera:
      return "Camera"
    case .touchscreen:
      return "Touch Screen"
    case .sim:
      return "SIM"
    case .wifi:
      return "Wi-Fi"
    case .biometric:
      return "Biometric"
    case .accelerometer:
      return "Accelerometer"
    case .bluetooth:
      return "Bluetooth"
    case .gps:
      return "GPS"
    case .homeButton:
      return "Home Button"
    case .mainSpeaker:
      return "Main Speaker"
    case .earSpeaker:
      return "Ear Speaker"
    case .proximity:
      return "Proximity"
    case .deadpixel:
      return "Dead Pixel"
    case .rotation:
      return "Rotation"
    case .microphone:
      return "Microphone"
    }
  }
  
  var value: String {
    switch self {
    case .cpu:
      return "Test the performance of your device's CPU"
    case .storage:
      return "Ensure your device's storage is functioning optimally"
    case .batteryStatus:
      return "Check the health of your device's battery"
    case .rootStatus:
      return "Verify if your device has been jailbroken"
    case .silentSwitch:
      return "Test the functionality of your device's silent switch"
    case .volumeUp:
      return "Ensure the volume up button is responsive"
    case .volumeDown:
      return "Check the responsiveness of the volume down button"
    case .powerButton:
      return "Verify the functionality of the power button"
    case .vibration:
      return "Test if the vibration motor is working correctly"
    case .camera:
      return "Ensure the camera functionality is intact"
    case .touchscreen:
      return "Check the responsiveness of the touch screen"
    case .sim:
      return "Verify the status of your SIM card"
    case .wifi:
      return "Test the connectivity of your device to Wi-Fi networks"
    case .biometric:
      return "Ensure the functionality of biometric authentication"
    case .accelerometer:
      return "Test the accelerometer sensor of your device"
    case .bluetooth:
      return "Verify the Bluetooth connectivity of your device"
    case .gps:
      return "Check the accuracy of GPS functionality on your device"
    case .homeButton:
      return "Test the responsiveness of the home button"
    case .mainSpeaker:
      return "Ensure the main speaker is producing sound properly"
    case .earSpeaker:
      return "Test the functionality of the ear speaker"
    case .proximity:
      return "Check the functionality of the proximity sensor"
    case .deadpixel:
      return "Detect any dead pixels on your device's screen"
    case .rotation:
      return "Verify if the screen rotation feature is working"
    case .microphone:
      return "Test the microphone's recording capability"
    }
  }
  
  var finishedMessage: String {
      switch self {
      case .cpu:
          return "📱 CPU is healthy!"
      case .storage:
          return "🫙 Storage is safe!"
      case .batteryStatus:
          return "🔋 Battery is healthy!"
      case .rootStatus:
          return "🔏 Root status verified!"
      case .silentSwitch:
          return "🔕 Silent Switch worked!"
      case .volumeUp:
          return "🔊 Volume up button is responsive!"
      case .volumeDown:
          return "🔈 Volume down button is responsive!"
      case .powerButton:
          return "📵 Power button is functioning properly!"
      case .vibration:
          return "🫨 Vibration motor is working correctly!"
      case .camera:
          return "📸 Camera functionality is intact!"
      case .touchscreen:
          return "👆 Touch screen is responsive!"
      case .sim:
          return "📶 SIM card status verified!"
      case .wifi:
          return "🛜 Wi-Fi connectivity tested!"
      case .biometric:
          return "🪪 Biometric working properly!"
      case .accelerometer:
          return "📏 Accelerometer sensor tested!"
      case .bluetooth:
          return "🚹 Bluetooth connectivity verified!"
      case .gps:
          return "🌐 GPS functionality checked!"
      case .homeButton:
          return "🏠 Home button is responsive!"
      case .mainSpeaker:
          return "📻 Speaker producing sound properly!"
      case .earSpeaker:
          return "🎧 Ear speaker functionality tested!"
      case .proximity:
          return "⚠️ Proximity sensor worked!"
      case .deadpixel:
          return "💀 No dead pixels detected on the screen!"
      case .rotation:
          return "🔄 Screen rotation feature verified!"
      case .microphone:
          return "🎙️ Microphone recording capability tested!"
      }
  }
  
  var testingMessage: String {
    switch self {
    case .silentSwitch:
      return "🔕 Turn On/Off the silent switch"
    case .volumeUp:
      return "🔊 Press the volume up button"
    case .volumeDown:
      return "🔈 Press the volume down button"
    case .powerButton:
      return "📵 Press the power button"
    case .wifi:
      return "🛜 Connect to a Wi-Fi network"
    case .sim:
      return "📶 Turn On Celullar"
    case .bluetooth:
      return "🚹 Turn On/Off Bluetooth"
    case .gps:
      return "🌐 Check GPS signal"
    case .microphone:
      return "🎙️ Test microphone recording"
    case .earSpeaker:
      return "🎧 Put your phone like a call"
    case .mainSpeaker:
      return "📻 Playing a sound..."
    case .vibration:
      return "🫨 Check if the device vibrates"
    case .proximity:
      return "⚠️ Cover your screen"
    default:
      return ""
    }
  }


}
