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
      
        if let input = try? AVCaptureDeviceInput(device: front) {
            if session.canAddInput(input) {
                session.addInputWithNoConnections(input)
                
                if let port = input.ports(
                    for: .video,
                    sourceDeviceType: front.deviceType,
                    sourceDevicePosition: front.position
                ).first {
                    session.addConnection(AVCaptureConnection(inputPort: port, videoPreviewLayer: frontLayer))
                }
            }
        }
        
        if let input = try? AVCaptureDeviceInput(device: back) {
            if session.canAddInput(input) {
                session.addInputWithNoConnections(input)
                
                if let port = input.ports(
                    for: .video,
                    sourceDeviceType: back.deviceType,
                    sourceDevicePosition: back.position
                ).first {
                    session.addConnection(AVCaptureConnection(inputPort: port, videoPreviewLayer: backLayer))
                }
            }
        }

        session.commitConfiguration()
        session.startRunning()
    }
    
    enum Error: Swift.Error {
        case failedToAuthorizeSessionForVideo
        case missingFrontVideo
        case missingBackVideo
    }
    
}
