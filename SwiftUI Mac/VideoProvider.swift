import AVFoundation

class VideoProvider: NSObject {
    
    private let session = AVCaptureSession()
    
    lazy var layer:AVCaptureVideoPreviewLayer = {
        let l = AVCaptureVideoPreviewLayer(session: session)
        l.videoGravity = .resizeAspectFill
        return l
    }()
    
    private let discover = AVCaptureDevice.DiscoverySession(
        deviceTypes: [.builtInWideAngleCamera],
        mediaType: .video,
        position: .unspecified
    )
    
    func setup() {
        if AVCaptureDevice.authorizationStatus(for: .video) != .authorized {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { authed in
                if authed { self.setup() }
            })
        } else {
            guard let device = discover.devices.first else { return }
        
            session.beginConfiguration()
            session.sessionPreset = .high
            
            if let input = try? AVCaptureDeviceInput(device: device) {
                if session.canAddInput(input) {
                    session.addInput(input)
                }
            }
            
            session.commitConfiguration()
            session.startRunning()
        }
    }
    
}
