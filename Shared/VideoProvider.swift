import AVFoundation

final class VideoProvider: NSObject {
    
    private let session = AVCaptureMultiCamSession()
    
    lazy var frontLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(sessionWithNoConnection: session)
        layer.videoGravity = .resizeAspectFill
        return layer
    }()
    
    lazy var backLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(sessionWithNoConnection: session)
        layer.videoGravity = .resizeAspectFill
        return layer
    }()
    
    private let discover = AVCaptureDevice.DiscoverySession(
        deviceTypes: [.builtInWideAngleCamera],
        mediaType: .video,
        position: .unspecified
    )
    
    private func attach(device: AVCaptureDevice, to layer: AVCaptureVideoPreviewLayer) throws {
        let input = try AVCaptureDeviceInput(device: device)
        guard session.canAddInput(input) else { return }
        
        session.addInputWithNoConnections(input)
        
        if let port = input.ports(
            for: .video,
            sourceDeviceType: device.deviceType,
            sourceDevicePosition: device.position
        ).first {
            session.addConnection(AVCaptureConnection(inputPort: port, videoPreviewLayer: layer))
        }
    }
    
    func setup() async throws {
        if AVCaptureDevice.authorizationStatus(for: .video) != .authorized {
            let didAuthorize = await AVCaptureDevice.requestAccess(for: .video)
            
            if !didAuthorize {
                throw Error.failedToAuthorizeSessionForVideo
            }
        }
        
        guard let front = discover.devices.first(where: { $0.position == .front }) else {
            throw Error.missingFrontVideo
        }
        
        guard let back = discover.devices.first(where: { $0.position == .back }) else {
            throw Error.missingBackVideo
        }
        
        session.beginConfiguration()
      
        try attach(device: front, to: frontLayer)
        try attach(device: back, to: backLayer)

        session.commitConfiguration()
        session.startRunning()
    }
    
    enum Error: Swift.Error {
        case failedToAuthorizeSessionForVideo
        case missingFrontVideo
        case missingBackVideo
    }
    
}
