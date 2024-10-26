//
//  DeadpixelFunctionalityView.swift
//  DeviceFunctionality
//
//  Created by Uwais Alqadri on 8/9/24.
//

import SwiftUI

struct DeadpixelFunctionalityView: View {
  @StateObject var presenter: DeadpixelFunctionalityPresenter

  init() {
    _presenter = StateObject(
      wrappedValue: DeadpixelFunctionalityPresenter()
    )
  }

  var body: some View {
    ZStack {
      switch presenter.state.index {
      case 0:
        Color.red
      case 1:
        Color.green
      case 2:
        Color.blue
      case 3:
        Color.black
      case 4:
        Color.white
      default:
        Color.red
      }
    }
    .edgesIgnoringSafeArea(.all)
    .onAppear {
      presenter.send(.setTimer)
    }
  }
}

#Preview {
  DeadpixelFunctionalityView()
}
