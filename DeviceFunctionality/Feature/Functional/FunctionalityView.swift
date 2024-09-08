//
//  FunctionalityView.swift
//  SpecAsessment
//
//  Created by Uwais Alqadri on 13/12/23.
//

import SwiftUI
import DeviceKit
import CoreMotion
import AlertToast

struct FunctionalityView: View {

  @StateObject var presenter: FunctionalityPresenter
    
  init() {
    _presenter = StateObject(
      wrappedValue: FunctionalityPresenter()
    )
  }
  
  var body: some View {
    NavigationView {
      ScrollView {
        HStack(alignment: .top) {
          ForEach([FunctionalityPresenter.GridSide.right, FunctionalityPresenter.GridSide.left], id: \.self) { side in
            VStack(spacing: 12) {
              ForEach(Array(presenter.splitForGrid(side: side).enumerated()), id: \.offset) { _, item in
                FunctionalityRow(item: item, onTestFunction: {
                  presenter.send(.startAssessment(assessment: item))
                  presenter.send(.shouldShow(assessment: item, isPresented: true))
                })
                .padding(.horizontal, 3)
              }
            }
          }
        }
        .padding(.horizontal, 12)
        .padding(.top, 30)
        .padding(.bottom, 40)
      }
      .navigationTitle("Device Health")
    }
    .fullScreenCover(isPresented: $presenter.state.isTouchscreenPresented) {
      ScreenFunctionalityView()
    }
    .fullScreenCover(isPresented: $presenter.state.isCameraPresented) {
      EmptyView()
    }
    .fullScreenCover(isPresented: $presenter.state.isDeadpixelPresented) {
      DeadpixelFunctionalityView()
    }
    .toast(isPresenting: $presenter.state.isAssessmentPassed, duration: 3.4) {
      AlertToast(displayMode: .hud, type: .regular, title: presenter.state.toastContents.finished)
    }
    .toast(isPresenting: $presenter.state.currentAssessment.isRunning, duration: 1_000_000, tapToDismiss: false) {
      AlertToast(displayMode: .hud, type: .regular, title: presenter.state.toastContents.testing)
    }
  }
}

struct FunctionalityView_Previews: PreviewProvider {
  static var previews: some View {
    FunctionalityView()
  }
}
