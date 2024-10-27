//
//  CameraViewController.swift
//  inOS
//
//  Created by Uwais Alqadri on 27/10/24.
//

import AVFoundation
import SwiftUI
import Combine

struct CameraFunctionalityView: UIViewControllerRepresentable {
  @Environment(\.presentationMode) var presentation
  
  func makeUIViewController(context: Context) -> CameraAssessmentViewController {
    CameraAssessmentViewController(onDismiss: {
      presentation.wrappedValue.dismiss()
    })
  }
  
  func updateUIViewController(_ uiViewController: CameraAssessmentViewController, context: Context) {}
  
  typealias UIViewControllerType = CameraAssessmentViewController
}

class CameraAssessmentViewController: UIViewController {
  
  let onDismiss: () -> Void
  
  init(onDismiss: @escaping () -> Void) {
    self.onDismiss = onDismiss
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
    
  var isCheckingFrontCamera = false
  var isFrontCameraUndetected = false
  var isBackCameraUndetected = false
  var isCameraNoAccess = false
  var cancellables = Set<AnyCancellable>()
  
  private var limitTime = 7
  private var cameraSessionTimer: Timer?
  private var images: [UIImage] = []
  private var captureSession: AVCaptureSession?
  private var photoOutput: AVCapturePhotoOutput?
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if captureSession?.isRunning == false {
      startCaptureSession()
    }
    
    startCameraSessionTimer()
    
    setupAndCaptureDefaultCamera {
      self.capturePhoto()
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    if captureSession?.isRunning == true {
      captureSession?.stopRunning()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    observeValues()
  }
  
  private func observeValues() {
    NotificationCenter.default.publisher(for: .AVCaptureSessionRuntimeError)
      .sink { [weak self] _ in
        self?.stopCameraWhenFailed()
      }
      .store(in: &cancellables)
  }
  
  private func capturePhoto() {
    let settings = AVCapturePhotoSettings()
    guard let photoOutput = self.photoOutput else { return }
    photoOutput.capturePhoto(with: settings, delegate: self)
  }
  
  private func setupAndCaptureDefaultCamera(onCapture: @escaping () -> Void) {
    captureSession = AVCaptureSession()
    
    if let captureDevice = AVCaptureDevice.default(for: .video) {
      do {
        let input = try AVCaptureDeviceInput(device: captureDevice)
        if let captureSession = captureSession, captureSession.canAddInput(input) {
          captureSession.addInput(input)
          
          // Create a video preview layer to display the camera feed
          let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
          previewLayer.videoGravity = .resizeAspectFill
          previewLayer.frame = view.layer.bounds
          view.layer.addSublayer(previewLayer)
          
          photoOutput = AVCapturePhotoOutput()
          if let photoOutput = photoOutput, captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
            delay(bySeconds: 1.0) {
              onCapture()
            }
          } else {
            stopCameraWhenFailed()
          }
          
          startCaptureSession()
        } else {
          stopCameraWhenFailed()
        }
      } catch {
        stopCameraWhenFailed()
      }
    }
  }
  
  private func setupAndCaptureFrontCamera(onCapture: @escaping () -> Void) {
    guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
      stopCameraWhenFailed()
      return
    }
    
    do {
      // Remove existing input
      if let captureSession = captureSession,
        let currentInput = captureSession.inputs.first {
        captureSession.removeInput(currentInput)
      }
      
      // Add input for the front camera
      let input = try AVCaptureDeviceInput(device: captureDevice)
      
      if let captureSession = captureSession, captureSession.canAddInput(input) {
        captureSession.addInput(input)
        self.startCaptureSession()
        
        isCheckingFrontCamera = true
        
        delay(bySeconds: 1.0) {
          onCapture()
        }
      } else {
        stopCameraWhenFailed()
      }
    } catch {
      stopCameraWhenFailed()
    }
  }
  
  private func startCaptureSession() {
    DispatchQueue.global(qos: .background).async {
      self.captureSession?.startRunning()
    }
  }
  
  private func startCameraSessionTimer() {
    cameraSessionTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
      if self.limitTime > 0 {
        self.limitTime -= 1
      } else {
        timer.invalidate()
        self.limitTime = 0
        self.stopCameraWhenFailed()
      }
    }
  }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraAssessmentViewController: AVCapturePhotoCaptureDelegate {
  func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
    guard error == nil, let imageData = photo.fileDataRepresentation(), let uiImage = UIImage(data: imageData) else {
      stopCameraWhenFailed()
      return
    }
        
    if !isCheckingFrontCamera {
      checkCameraDetectBright(uiImage: uiImage) {
        delay(bySeconds: 1.0) {
          self.captureSession?.stopRunning()
          self.setupAndCaptureFrontCamera {
            self.capturePhoto()
          }
        }
      }
    } else {
      checkCameraDetectBright(uiImage: uiImage) {
        onDismiss()
        delay(bySeconds: 0.5) {
          Notifications.didCameraPassed.post(with: 1)
          self.cameraSessionTimer?.invalidate()
        }
      }
    }
    
    self.images.append(uiImage)
  }
  
  private func checkCameraDetectBright(uiImage: UIImage, onDetected: () -> Void) {
    let brightness = uiImage.averageBrightness()
    if brightness < 0.008 {
      stopCameraWhenFailed()
    } else if brightness > 0.008 {
      onDetected()
    }
  }
  
  private func stopCameraWhenFailed() {
    cameraSessionTimer?.invalidate()
    captureSession?.stopRunning()
    if isCheckingFrontCamera {
      isFrontCameraUndetected = true
    } else {
      isBackCameraUndetected = true
    }
  }
}

extension UIImage {
  func averageBrightness() -> CGFloat {
    guard let cgImage = self.cgImage else { return 0.0 }
    
    let imageData = cgImage.dataProvider?.data
    let data: UnsafePointer<UInt8> = CFDataGetBytePtr(imageData)
    let length: Int = CFDataGetLength(imageData)
    var totalBrightness: CGFloat = 0.0
    
    for index in stride(from: 0, to: length, by: 4) {
      let red = CGFloat(data[index])
      let green = CGFloat(data[index + 1])
      let blue = CGFloat(data[index + 2])
      let brightness = (0.299 * red + 0.587 * green + 0.114 * blue) / 255.0
      totalBrightness += brightness
    }
    
    return totalBrightness / CGFloat(length / 4)
  }
}
