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
    NavigationView {
      ScrollView {
        VStack(spacing: 12) {
          HStack(spacing: 12) {
            FunctionalityRow(icon: "📱", title: "CPU", value: "Let's see if something weird happens on this")
            FunctionalityRow(icon: "🫙", title: "Storage", value: "Let's see if something weird happens on this")
          }
          .padding(.horizontal, 12)
          .padding(.top, 20)
          
          HStack(spacing: 12) {
            FunctionalityRow(icon: "🔋", title: "Battery", value: "Let's see if something weird happens on this")
            FunctionalityRow(icon: "🔏", title: "Jailbreak", value: "Let's see if something weird happens on this")
          }.padding(.horizontal, 12)
          
          HStack(spacing: 12) {
            FunctionalityRow(icon: "🔕", title: "Silent Switch", value: "Let's see if something weird happens on this")
            FunctionalityRow(icon: "🔊", title: "Volume Up", value: "Let's see if something weird happens on this")
          }.padding(.horizontal, 12)
          
          HStack(spacing: 12) {
            FunctionalityRow(icon: "🔈", title: "Volume Down", value: "Let's see if something weird happens on this")
            FunctionalityRow(icon: "📵", title: "Power Button", value: "Let's see if something weird happens on this")
          }.padding(.horizontal, 12)
          
          HStack(spacing: 12) {
            FunctionalityRow(icon: "🫨", title: "Vibration", value: "Let's see if something weird happens on this")
            FunctionalityRow(icon: "📸", title: "CPU", value: "Let's see if something weird happens on this")
          }.padding(.horizontal, 12)
          
          HStack(spacing: 12) {
            FunctionalityRow(icon: "👆", title: "Touch Screen", value: "Let's see if something weird happens on this")
            FunctionalityRow(icon: "📶", title: "SIM", value: "Let's see if something weird happens on this")
          }.padding(.horizontal, 12)
          
          HStack(spacing: 12) {
            FunctionalityRow(icon: "🛜", title: "WIFI", value: "Let's see if something weird happens on this")
            FunctionalityRow(icon: "🪪", title: "Biometric", value: "Let's see if something weird happens on this")
          }.padding(.horizontal, 12)
          
          HStack(spacing: 12) {
            FunctionalityRow(icon: "📏", title: "Accelerometer", value: "Let's see if something weird happens on this")
            FunctionalityRow(icon: "🚹", title: "Bluetooth", value: "Let's see if something weird happens on this")
          }.padding(.horizontal, 12)
          
          HStack(spacing: 12) {
            FunctionalityRow(icon: "🌐", title: "GPS", value: "Let's see if something weird happens on this")
            FunctionalityRow(icon: "🏠", title: "Home Button", value: "Let's see if something weird happens on this")
          }.padding(.horizontal, 12)
          
          HStack(spacing: 12) {
            FunctionalityRow(icon: "📻", title: "Main Speaker", value: "Let's see if something weird happens on this")
            FunctionalityRow(icon: "🎧", title: "Ear Speaker", value: "Let's see if something weird happens on this")
          }.padding(.horizontal, 12)
          
          HStack(spacing: 12) {
            FunctionalityRow(icon: "⚠️", title: "Proximity", value: "Let's see if something weird happens on this")
            FunctionalityRow(icon: "💀", title: "Deadpixel", value: "Let's see if something weird happens on this")
          }.padding(.horizontal, 12)
          
          HStack(spacing: 12) {
            FunctionalityRow(icon: "🔄", title: "Rotation", value: "Let's see if something weird happens on this")
            FunctionalityRow(icon: "🎙️", title: "Microphone", value: "Let's see if something weird happens on this")
          }.padding(.horizontal, 12)
          
          Spacer()
        }
      }
      .navigationTitle("Device Health")
    }
  }
}

struct AssessmentView_Previews: PreviewProvider {
  static var previews: some View {
    AssessmentView(presenter: AssessmentPresenter())
  }
}
