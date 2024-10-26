//
//  ScreenFunctionalityView.swift
//  DeviceFunctionality
//
//  Created by Uwais Alqadri on 8/9/24.
//

import SwiftUI

struct ScreenFunctionalityView: View {
  @StateObject var presenter: ScreenFunctionalityPresenter

  init() {
    _presenter = StateObject(
      wrappedValue: ScreenFunctionalityPresenter()
    )
  }

  var body: some View {
    GeometryReader { geometry in
      VStack(spacing: 1) {
        ForEach(0..<presenter.state.rows, id: \.self) { row in
          HStack(spacing: 1) {
            ForEach(0..<presenter.state.columns, id: \.self) { column in
              Rectangle()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundColor(presenter.state.boxes[presenter.indexFor(row: row, column: column)])
                .gesture(
                  TapGesture().onEnded { _ in
                    presenter.send(.handleTap(row: row, column: column))
                  }
                )
            }
          }
        }
      }
      .background(Color.white)
      .gesture(
        DragGesture(minimumDistance: 0)
          .onChanged { gesture in
            presenter.send(.handleDragGesture(gesture: gesture, geometry: geometry))
          }
          .onEnded { _ in
            presenter.send(.timerPause)
          }
      )
    }
    .ignoresSafeArea(.all)
    .onAppear {
      presenter.send(.startCountdown)
    }
    .onDisappear {
      presenter.send(.invalidateTimer)
    }
    .overlay(
      Text("\(presenter.state.countdownValue)")
        .font(.system(size: 96, weight: .bold))
        .foregroundColor(Color.black.opacity(0.4))
    )
  }
}

#Preview {
  ScreenFunctionalityView()
}
