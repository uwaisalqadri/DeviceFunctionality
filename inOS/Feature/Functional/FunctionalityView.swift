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
  @State var isIntroduction: Bool = true
  @AppStorage("isDarkMode") var isDarkMode: Bool = false
  
  init() {
    _presenter = StateObject(
      wrappedValue: FunctionalityPresenter()
    )
  }

  var body: some View {
    NavigationView {
      ScrollView {
        VStack {
          HStack(spacing: 6) {
            ForEach(
              Array(presenter.state.deviceStatuses.enumerated()),
              id: \.offset
            ) { _, status in
              Spacer()
              
              Button(action: {
                if status.isOther {
                  presenter.state.isSpecificationPresented.toggle()
                }
              }) {
                VStack(spacing: 4) {
                  Image(systemName: status.spec.icon)
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
                  Text(status.value)
                    .font(.system(size: 12))
                    .bold()
                }
              }
              .buttonStyle(.plain)
              
              Spacer()
            }
          }
          .frame(height: 60)
          .background(
            RoundedRectangle(cornerRadius: 12)
              .fill(Color.gray.opacity(0.1))
          )
          .padding(.bottom, 6)
          
          HStack(alignment: .top) {
            ForEach(FunctionalityPresenter.GridSide.allCases, id: \.self) { side in
              VStack(spacing: 12) {
                ForEach(Array(presenter.splitForGrid(side: side).enumerated()), id: \.offset) { _, item in
                  let isPassed = presenter.state.passedAssessments[item] ?? false
                  FunctionalityRow(item: item, isPassed: isPassed, onTestFunction: {
                    presenter.send(.start(assessment: item))
                  })
                  .padding(.horizontal, 3)
                }
              }
            }
          }
        }
        .padding(.horizontal, 12)
        .padding(.top, 30)
        .padding(.bottom, 40)
      }
      .onAppear {
        presenter.send(.loadStatus)
      }
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          let device = presenter.state.deviceStatus
          HStack(spacing: 4) {
            Image(systemName: device.spec.icon)
              .font(.system(size: 20))
              .foregroundColor(.blue)
            Text(device.value)
              .font(.system(size: 14, weight: .semibold))
          }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
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

        ToolbarItem(placement: .topBarTrailing) {
          Button(action: {
            isDarkMode.toggle()
            UIApplication.shared.windows.first?
              .rootViewController?
              .overrideUserInterfaceStyle = isDarkMode ? .dark : .light
          }) {
            Image(systemName: isDarkMode ? "sun.max" : "moon")
              .resizable()
              .scaleEffect(1)
          }
        }
      }
    }
    .sheet(isPresented: $isIntroduction) {
      IntroductionView(onStart: {
        isIntroduction = false
      })
    }
    .alert(isPresented: $presenter.state.isConfirmSerial) {
      serialConfirmAlert()
    }
    .fullScreenCover(isPresented: $presenter.state.isSpecificationPresented) {
      SpecificationView([
        .init(title: "Model", value: "iPhone 12 Mini"),
        .init(title: "Model", value: "iPhone 12 Mini"),
        .init(title: "Model", value: "iPhone 12 Mini"),
      ])
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
    .toast(isPresenting: $presenter.state.currentAssessment.isRunning, duration: .infinity, tapToDismiss: true) {
      AlertToast(displayMode: .hud, type: .regular, title: presenter.state.toastContents.testing)
    }
  }
  
  private func serialConfirmAlert() -> Alert {
    Alert(
      title: Text("Do Serial Tests?"),
      message: Text("By starting serial tests, all test will automatically start one after another"),
      primaryButton: .default(Text("Start")) {
        if presenter.state.isSerialRunning {
          presenter.send(.terminateSerial)
        } else {
          presenter.send(.confirmSerial)
          presenter.send(.runSerial)
        }
      },
      secondaryButton: .cancel()
    )
  }
}

struct FunctionalityView_Previews: PreviewProvider {
  static var previews: some View {
    FunctionalityView()
  }
}
