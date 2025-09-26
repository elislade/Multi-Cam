import CoreGraphics


enum Corner: Equatable, Sendable, BitwiseCopyable {
    
    case topLeading, topTrailing, bottomLeading, bottomTrailing
    
    var horizontalEdge: HorizontalEdge {
        switch self {
        case .topLeading, .bottomLeading: .leading
        case .topTrailing, .bottomTrailing: .trailing
        }
    }
    
    var verticalEdge: VerticalEdge {
        switch self {
        case .topLeading, .topTrailing: .top
        case .bottomLeading, .bottomTrailing: .bottom
        }
    }
    
    enum HorizontalEdge: Equatable, Sendable, BitwiseCopyable {
        case leading, trailing
    }
    
    enum VerticalEdge: Equatable, Sendable, BitwiseCopyable {
        case top, bottom
    }
    
}


extension Corner {
    
    static func nearest(to point: CGPoint, in rect: CGRect) -> Corner {
        if point.y > rect.midY && point.x > rect.midX { return .bottomTrailing } else
        if point.y > rect.midY && point.x <= rect.midX { return .bottomLeading } else
        if point.y <= rect.midY && point.x > rect.midX { return .topTrailing } else {
            return .topLeading
        }
    }
    
}
