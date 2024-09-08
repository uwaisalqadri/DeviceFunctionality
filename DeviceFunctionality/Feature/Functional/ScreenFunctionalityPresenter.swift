//
//  ScreenFunctionalityPresenter.swift
//  DeviceFunctionality
//
//  Created by Uwais Alqadri on 8/9/24.
//

import Foundation
import SwiftUI

@MainActor
class ScreenFunctionalityPresenter: ObservableObject {

  @Published var state = State()

  func send(_ action: Action) {
    switch action {
    case let .handleDragGesture(gesture, geometry):
      handleDragGesture(gesture, geometry: geometry)

    case let .handleTap(row, column):
      handleTap(row: row, column: column)

    case .timerPause:
      state.isTimerPaused = false

    case .invalidateTimer:
      state.timer?.invalidate()

    case .startCountdown:
      startCountdown()

    case .updateCountdown:
      updateCountdown()

    case .resetCountdown:
      resetCountdown()

    case .resetAllState:
      resetAllState()

    case .success:
      Notifications.didTouchScreenPassed.post(with: true)

    case .failed:
      Notifications.didTouchScreenPassed.post(with: false)
    }
  }

  func indexFor(row: Int, column: Int) -> Int {
    return row * state.columns + column
  }
}

extension ScreenFunctionalityPresenter {
  private func handleTap(row: Int, column: Int) {
    let index = indexFor(row: row, column: column)
    if state.boxes[index] == .blue {
      state.boxes[index] = .white
      resetCountdown()
    }
  }

  private func handleDragGesture(_ gesture: DragGesture.Value, geometry: GeometryProxy) {
    let cellWidth = geometry.size.width / CGFloat(state.columns)
    let cellHeight = geometry.size.height / CGFloat(state.rows)

    let xPosition = Int(gesture.location.x / cellWidth)
    let yPosition = Int(gesture.location.y / cellHeight)

    let boxIndex = self.indexFor(row: yPosition, column: xPosition)

    if state.boxes[boxIndex] == .blue {
      state.boxes[boxIndex] = .white
      state.isTimerPaused = false
      resetCountdown()
    } else {
      state.isTimerPaused = true
      updateCountdown()
    }
  }

  private func resetCountdown() {
    state.countdownValue = 10
    startCountdown()
  }

  private func startCountdown() {
    state.timer?.invalidate()
    state.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
      self.updateCountdown()
    }
  }

  private func updateCountdown() {
    if !state.isTimerPaused {
      state.countdownValue -= 1

      if state.countdownValue == 0 {
        state.timer?.invalidate()
        send(.failed)
      }

      if state.boxes.allSatisfy({ $0 == .white }) {
        state.timer?.invalidate()
        send(.success)
      }
    }
  }

  private func resetAllState() {
    state.boxes = Array(repeating: .blue, count: 13 * 19)
    state.countdownValue = 10
    state.timer?.invalidate()
    startCountdown()
  }
}
