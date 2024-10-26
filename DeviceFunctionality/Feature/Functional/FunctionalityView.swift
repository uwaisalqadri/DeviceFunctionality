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
  @AppStorage("isIntroduction") var isIntroduction: Bool = true
  @AppStorage("isDarkMode") var isDarkMode: Bool = false
  
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
                let isPassed = presenter.state.passedAssessments[item] ?? false
                FunctionalityRow(item: item, isPassed: isPassed, onTestFunction: {
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
    .sheet(isPresented: $isIntroduction) {
      VStack(spacing: 16) {
        let appName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String
        Text("Welcome to \(appName ?? "???")")
          .font(.title)
          .bold()
          .multilineTextAlignment(.center)
        
        Text("This app is an utility app to perform serial of testing to check whether your phone is working with great functionality or not")
          .multilineTextAlignment(.center)
        
        Divider()
        
        VStack(alignment: .leading) {
          Text("• Serial Text")
          Text("• Assessment Text")
          Text("• BAM BAM BAM")
        }
        
        Spacer()
        
        Divider()
        
        Button(action: {
          isIntroduction = false
        }) {
          Text("Start")
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: 60)
        .buttonStyle(.plain)
        .background(Color.blue.clipShape(Capsule()))
      }
      .padding(.top, 16)
      .padding(16)
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
