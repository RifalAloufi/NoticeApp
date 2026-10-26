import AVFoundation

enum CameraPermission {
    static func request() async -> Bool {
        #if targetEnvironment(simulator)
        return true
#else
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)
        default:
            return false    // denied أو restricted
        }
        #endif
    }
}
