//
//  ScreenFunctionalityPresenter+StateAction.swift
//  DeviceFunctionality
//
//  Created by Uwais Alqadri on 8/9/24.
//

import Foundation
import SwiftUI

extension ScreenFunctionalityPresenter {
  struct State {
    var boxes: [Color] = Array(repeating: .blue, count: 13 * 19)
    var countdownValue = 10
    var timer: Timer?
    var isTimerPaused = false

    var rows: Int = 19
    var columns: Int = 13
  }

  enum Action {
    case handleDragGesture(gesture: DragGesture.Value, geometry: GeometryProxy)
    case handleTap(row: Int, column: Int)
    case startCountdown
    case updateCountdown
    case resetCountdown
    case resetAllState
    case timerPause
    case invalidateTimer
    case success
    case failed
  }
}
