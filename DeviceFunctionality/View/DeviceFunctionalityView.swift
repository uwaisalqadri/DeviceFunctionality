//
//  DeviceFunctionalityView.swift
//  SpecAsessment
//
//  Created by Uwais Alqadri on 13/12/23.
//

import SwiftUI
import DeviceKit
import CoreMotion
import AlertToast

struct DeviceFunctionalityView: View {
  
  @StateObject var presenter: FunctionalityPresenter = FunctionalityPresenter()
    
  var body: some View {
    NavigationView {
      ScrollView {
        HStack(alignment: .top) {
          VStack(spacing: 12) {
            ForEach(Array(presenter.splitForGrid(side: .right).enumerated()), id: \.offset) { _, item in
              FunctionalityRow(item: item, onTestFunction: {
                presenter.runningAssessment(for: item)
              })
              .padding(.horizontal, 3)
            }
          }
          
          VStack(spacing: 12) {
            ForEach(Array(presenter.splitForGrid(side: .left).enumerated()), id: \.offset) { _, item in
              FunctionalityRow(item: item, onTestFunction: {
                presenter.runningAssessment(for: item)
              })
              .padding(.horizontal, 3)
            }
          }
        }
        .padding(.horizontal, 12)
        .padding(.top, 30)
        .padding(.bottom, 40)
      }
      .navigationTitle("Device Health")
    }
    .toast(isPresenting: $presenter.isAssessmentPassed, duration: 3.4) {
      AlertToast(displayMode: .hud, type: .regular, title: presenter.currentAssessment.assessment.finishedMessage)
    }
    .toast(isPresenting: $presenter.currentAssessment.isRunning, duration: 1_000_000, tapToDismiss: false) {
      AlertToast(displayMode: .hud, type: .regular, title: presenter.currentAssessment.assessment.testingMessage)
    }
  }
}

struct DeviceFunctionalityView_Previews: PreviewProvider {
  static var previews: some View {
    DeviceFunctionalityView(presenter: FunctionalityPresenter())
  }
}
