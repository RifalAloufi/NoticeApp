import AVFoundation

enum CameraPermission {
    // Asks for camera access (the system prompt shows the first time).
    // Used by Home before the capture screen opens.
    static func request() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)
        default:
            return false    // denied or restricted
        }
    }
}
