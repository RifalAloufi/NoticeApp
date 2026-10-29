import SwiftUI
struct CaptureFlowView: View {
    let questTitle: String
    var onSaved: ((UIImage) -> Void)? = nil
    var onFinish: () -> Void = {}
    private enum Step { case camera, afterCapture }

    @StateObject private var camera = CameraManager()
    @State private var step: Step = .camera
    @State private var capturedPhoto: UIImage? = nil
    @State private var isCapturing = false
    @State private var saveFailed = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            switch step {
            case .camera:
                if camera.access == .denied {
                    CaptureAccessOffView(onClose: onFinish, onBackToHome: onFinish)
                } else {
                    CaptureCameraView(
                        questTitle: questTitle,
                        session: camera.session,
                        zoom: camera.zoom,
                        isShutterDisabled: isCapturing || camera.access != .authorized,
                        onClose: onFinish,
                        onShutter: takePhoto,
                        onZoomChange: { camera.setZoom($0) },
                        onFlip: { camera.flipCamera() }
                    )
                }

            case .afterCapture:
                AfterCaptureView(
                    questTitle: questTitle,
                    photo: capturedPhoto.map { Image(uiImage: $0) },
                    onClose: onFinish,
                    onRetake: retake,
                    onSave: save
                )
            }
        }
        .onAppear { camera.checkAccess() }
        .onDisappear { camera.stop() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { camera.checkAccess() }
        }
        .alert("Couldn't save the photo", isPresented: $saveFailed) {
            Button("OK", role: .cancel) {}
        }
    }

    private func takePhoto() {
        isCapturing = true
        camera.capturePhoto { image in
            isCapturing = false
            guard let image else { return }
            capturedPhoto = PhotoStorage.resized(image)   // resizing the photo
            withAnimation { step = .afterCapture }
        }
    }

    private func retake() {
        capturedPhoto = nil
        withAnimation { step = .camera }
    }

    private func save() {
        guard let capturedPhoto else { return }
        do {
            try PhotoStorage.save(capturedPhoto, quest: questTitle)
            onSaved?(capturedPhoto)
            onFinish()
        } catch {
            saveFailed = true
        }
    }
}

#Preview {
    CaptureFlowView(questTitle: "Find something orange")
}
