//
//  DeviceAsessmentApp.swift
//  SpecAsessment
//
//  Created by Uwais Alqadri on 13/12/23.
//

import SwiftUI
import CoreMotion

@main
struct DeviceAsessmentApp: App {
  var body: some Scene {
    WindowGroup {
      AssessmentView(presenter: AssessmentPresenter())
    }
  }
}
