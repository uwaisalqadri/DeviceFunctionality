//
//  FunctionalityPresenter.swift
//  DeviceAssessment
//
//  Created by Uwais Alqadri on 6/1/24.
//

import SwiftUI
import Combine
import DeviceKit
import AudioToolbox
import Foundation

@MainActor
class FunctionalityPresenter: ObservableObject {

  @Published var state = State()

  private lazy var drivers: [AssessmentTester.AssessmentDriverType: AssessmentDriver] = {
    let types: [AssessmentTester.AssessmentDriverType] = [.physicalActivity, .deviceInfo, .connectivity, .power]
    return Dictionary(uniqueKeysWithValues: types.map { type in
      (type, AssessmentTester(driver: type).driver)
    })
  }()

  private var cancellables = Set<AnyCancellable>()

  func send(_ action: Action) {
    switch action {
    case .start(let assessment):
      Task {
        await beginAssessment(for: assessment)
      }

    case .confirmSerial:
      state.isConfirmSerial.toggle()

    case .runSerial:
      startAssessmentsSerialized()

    case let .shouldShow(assessment, isPresented):
      switch assessment {
      case .camera:
        state.isCameraPresented = isPresented
      case .deadpixel:
        state.isDeadpixelPresented = isPresented
      case .touchscreen:
        state.isTouchscreenPresented = isPresented
      default:
        break
      }
    }
  }
}

extension FunctionalityPresenter {
  func startAssessmentsSerialized() {
    state.isSerialRunning = true
    let assessments = Assessment.allCases

    Task {
      for assessment in assessments {
        await self.beginAssessment(for: assessment, isSerial: true)
        send(.shouldShow(assessment: assessment, isPresented: true))
      }

      state.isSerialRunning = false
    }
  }

  func beginAssessment(for assessment: Assessment, isSerial: Bool = false) async {
    state.currentAssessment = (assessment, !assessment.testingMessage.isEmpty)
    state.isAssessmentPassed = false

    do {
      for try await isAssessmentPassed in streamAssessment(for: assessment) {
        self.state.currentAssessment = (assessment, false)
        self.state.isAssessmentPassed = isAssessmentPassed
      }
    } catch {
      print("Assessment failed for \(assessment): \(error)")
    }

    if isSerial {
      try? await Task.sleep(nanoseconds: 2_000_000_000)  // 2 seconds
    }
  }

  @MainActor
  func streamAssessment(for assessment: Assessment) ->  AsyncThrowingStream<Bool, Error> {
    return AsyncThrowingStream { continuation in
      switch assessment {
      case .cpu:
        if let cpu = drivers[.deviceInfo]?.assessments[assessment] as? CpuInformation {
          continuation.yield(cpu.model?.isEmpty != true)
          continuation.finish()
        }

      case .storage:
        drivers[.deviceInfo]?.startAssessment(for: assessment) { [drivers] in
          if let storage = drivers[.deviceInfo]?.assessments[assessment] as? Storage {
            continuation.yield(storage.totalSpace?.isEmpty != true)
            continuation.finish()
          }
        }

      case .batteryStatus:
        drivers[.power]?.startAssessment(for: assessment) { [drivers] in
          if let battery = drivers[.power]?.assessments[assessment] as? Battery {
            continuation.yield(battery.technology?.isEmpty != true)
            continuation.finish()
          }
        }

      case .rootStatus:
        continuation.yield(drivers[.deviceInfo]?.hasAssessmentPassed[assessment] ?? false)
        continuation.finish()

      case .volumeUp, .volumeDown, .biometric, .proximity, .accelerometer, .microphone:
        drivers[.physicalActivity]?.startAssessment(for: assessment) { [drivers] in
          if let reason = drivers[.physicalActivity]?.assessments[.biometric] as? BiometricFailedReason {
            continuation.finish(throwing: reason)
            return
          }

          if let failure = drivers[.physicalActivity]?.assessments[.microphone] as? PermissionFailed {
            continuation.finish(throwing: failure)
            return
          }

          continuation.yield(self.drivers[.physicalActivity]?.hasAssessmentPassed[assessment] ?? false)
          continuation.finish()
          drivers[.physicalActivity]?.stopAssessment(for: assessment)
        }

      case .silentSwitch:
        drivers[.physicalActivity]?.startAssessment(for: assessment) { [drivers] in
          continuation.yield(self.drivers[.physicalActivity]?.hasAssessmentPassed[assessment] ?? false)
          continuation.finish()
          drivers[.physicalActivity]?.stopAssessment(for: assessment)
        }

      case .powerButton:
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
          .map { _ in true }
          .sink { isTriggered in
            let oldBrightness = UIScreen.main.brightness
            let newBrightness = max(0.01, min(1.0, oldBrightness + (oldBrightness <= 0.01 ? 0.01 : -0.01)))
            UIScreen.main.brightness = newBrightness
            continuation.yield(abs(oldBrightness - newBrightness) > 0.001)
            continuation.finish()
          }
          .store(in: &cancellables)

      case .camera:
        NotificationCenter.default.publisher(for: Notifications.didCameraPassed)
          .sink { notification in
            guard let isPassed = notification.object as? Bool else { return }
            continuation.yield(isPassed)
            continuation.finish()
            self.send(.shouldShow(assessment: assessment, isPresented: false))
          }
          .store(in: &cancellables)

      case .touchscreen:
        NotificationCenter.default.publisher(for: Notifications.didTouchScreenPassed)
          .sink { notification in
            guard let isPassed = notification.object as? Bool else { return }
            continuation.yield(isPassed)
            continuation.finish()
            self.send(.shouldShow(assessment: assessment, isPresented: false))
          }
          .store(in: &cancellables)

      case .sim, .wifi, .bluetooth, .gps:
        drivers[.connectivity]?.startAssessment(for: assessment) { [drivers] in
          continuation.yield(drivers[.connectivity]?.hasAssessmentPassed[assessment] ?? false)
          continuation.finish()
          drivers[.connectivity]?.stopAssessment(for: assessment)
        }

      case .homeButton:
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
          .map { _ in true }
          .sink { isTriggered in
            continuation.yield(isTriggered)
            continuation.finish()
          }
          .store(in: &cancellables)

      case .mainSpeaker, .earSpeaker, .vibration:
        drivers[.physicalActivity]?.startAssessment(for: assessment) {
          continuation.yield(true)
          continuation.finish()
          self.drivers[.physicalActivity]?.stopAssessment(for: assessment)
        }

      case .deadpixel:
        NotificationCenter.default.publisher(for: Notifications.didDeadpixelPassed)
          .sink { notification in
            guard let isPassed = notification.object as? Bool else { return }
            continuation.yield(isPassed)
            continuation.finish()
            self.send(.shouldShow(assessment: assessment, isPresented: false))
          }
          .store(in: &cancellables)

      case .rotation:
        NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
          .map { _ in true }
          .sink { isTriggered in
            continuation.yield(isTriggered)
            continuation.finish()
          }
          .store(in: &cancellables)

      }
    }
  }
}
