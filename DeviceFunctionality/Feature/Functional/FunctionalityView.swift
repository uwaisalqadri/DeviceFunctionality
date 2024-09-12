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
          ForEach(FunctionalityPresenter.GridSide.allCases, id: \.self) { side in
            VStack(spacing: 12) {
              ForEach(Array(presenter.splitForGrid(side: side).enumerated()), id: \.offset) { _, item in
                FunctionalityRow(item: item, onTestFunction: {
                  presenter.send(.start(assessment: item))
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
      .toolbar {
        ToolbarItem {
          Button(action: {
            presenter.send(.confirmSerial)
          }) {
            let rotation: Double = presenter.state.isSerialRunning ? 0 : 360
            Image(systemName: "goforward")
              .resizable()
              .scaleEffect(1)
              .rotationEffect(.degrees(rotation))
              .animation(presenter.state.isSerialRunning ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: rotation)
          }
        }
      }
    }
    .alert(isPresented: $presenter.state.isConfirmSerial) {
      Alert(
        title: Text("Do Serial Tests?"),
        message: Text("By starting serial tests, all test will automatically start one after another"),
        primaryButton: .default(Text("Start")) {
          presenter.send(.confirmSerial)
          presenter.send(.runSerial)
        },
        secondaryButton: .cancel()
      )
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
