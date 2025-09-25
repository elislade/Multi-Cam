import SwiftUI

extension Alignment {
    
    static func nearest(to point: CGPoint, in rect: CGRect) -> Alignment {
        if point.y > rect.midY && point.x > rect.midX { return .bottomTrailing } else
        if point.y > rect.midY && point.x <= rect.midX { return .bottomLeading } else
        if point.y <= rect.midY && point.x > rect.midX { return .topTrailing } else {
            return .topLeading
        }
    }
    
}
