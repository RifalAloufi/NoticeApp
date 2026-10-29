import SwiftUI
import Combine
import AVFoundation
import UIKit

// MARK: - Camera engine (AVFoundation)
nonisolated final class CameraManager: NSObject, ObservableObject, @unchecked Sendable {
    enum Access { case unknown, authorized, denied }

    @Published private(set) var access: Access = .unknown
    @Published private(set) var position: AVCaptureDevice.Position = .back   //camera switch
    @Published private(set) var zoom: CGFloat = 1                            // zoom in/out

    let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private let queue = DispatchQueue(label: "ntu.camera.session")
    private var configured = false
    private var device: AVCaptureDevice?
    private var activePosition: AVCaptureDevice.Position = .back
    private var completion: ((UIImage?) -> Void)?

    private let maxZoomLimit: CGFloat = 10

    // MARK: Permission
    func checkAccess() {
        #if targetEnvironment(simulator)
        access = .authorized
        #else
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            access = .authorized
            start()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.access = granted ? .authorized : .denied
                    if granted { self?.start() }
                }
            }
        default:
            access = .denied
            stop()
        }
        #endif
    }

    // MARK: Session
    func start() {
        queue.async { [weak self] in
            guard let self else { return }
            if !self.configured { self.configured = self.configure(position: self.activePosition) }
            if self.configured, !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }

    func stop() {
        queue.async { [weak self] in
            guard let self else { return }
            if self.session.isRunning { self.session.stopRunning() }
        }
    }

    //
    private func configure(position: AVCaptureDevice.Position) -> Bool {
        session.beginConfiguration()
        session.sessionPreset = .photo
        for input in session.inputs { session.removeInput(input) }

        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position),
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input)
        else {
            session.commitConfiguration()
            return false
        }
        session.addInput(input)

        if !session.outputs.contains(output) {
            guard session.canAddOutput(output) else {
                session.commitConfiguration()
                return false
            }
            session.addOutput(output)
        }
        session.commitConfiguration()

        self.device = device
        return true
    }

    // MARK: Flip front / back
    func flipCamera() {
        #if targetEnvironment(simulator)
        DispatchQueue.main.async {
            self.position = (self.position == .back) ? .front : .back
            self.zoom = 1
        }
        #else
        queue.async { [weak self] in
            guard let self, self.configured else { return }
            let target: AVCaptureDevice.Position = (self.activePosition == .back) ? .front : .back
            if self.configure(position: target) {
                self.activePosition = target
                DispatchQueue.main.async {
                    self.position = target
                    self.zoom = 1
                }
            } else {
                _ = self.configure(position: self.activePosition)
            }
        }
        #endif
    }

    // MARK: Zoom
    func setZoom(_ factor: CGFloat) {
        #if targetEnvironment(simulator)
        let clamped = max(1, min(factor, maxZoomLimit))
        DispatchQueue.main.async { self.zoom = clamped }
        #else
        queue.async { [weak self] in
            guard let self, let device = self.device else { return }
            let upper = min(device.maxAvailableVideoZoomFactor, self.maxZoomLimit)
            let clamped = max(device.minAvailableVideoZoomFactor, min(factor, upper))
            do {
                try device.lockForConfiguration()
                device.videoZoomFactor = clamped
                device.unlockForConfiguration()
            } catch {
                return
            }
            DispatchQueue.main.async { self.zoom = clamped }
        }
        #endif
    }

    // MARK: Capture
    func capturePhoto(_ completion: @escaping (UIImage?) -> Void) {
        #if targetEnvironment(simulator)
        completion(Self.placeholderImage())
        #else
        queue.async { [weak self] in
            guard let self, self.session.isRunning else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            self.completion = completion
            self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        }
        #endif
    }

    static func placeholderImage() -> UIImage {
        let size = CGSize(width: 900, height: 1200)
        return UIGraphicsImageRenderer(size: size).image { ctx in
            UIColor(white: 0.18, alpha: 1).setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
            let text = "Simulator photo" as NSString
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 56, weight: .medium),
                .foregroundColor: UIColor.white
            ]
            let textSize = text.size(withAttributes: attrs)
            text.draw(at: CGPoint(x: (size.width - textSize.width) / 2,
                                  y: (size.height - textSize.height) / 2),
                      withAttributes: attrs)
        }
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        let image = photo.fileDataRepresentation().flatMap { UIImage(data: $0) }
        let done = completion
        completion = nil
        DispatchQueue.main.async { done?(image) }
    }
}

struct LiveCameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> LiveCameraPreviewUIView {
        let view = LiveCameraPreviewUIView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: LiveCameraPreviewUIView, context: Context) {}
}

final class LiveCameraPreviewUIView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
}
