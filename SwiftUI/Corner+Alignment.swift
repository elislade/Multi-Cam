import SwiftUI

extension Corner.HorizontalEdge {
    
    var alignment: HorizontalAlignment {
        switch self {
        case .leading: .leading
        case .trailing: .trailing
        }
    }
    
}

extension Corner.VerticalEdge {
    
    var alignment: VerticalAlignment {
        switch self {
        case .top: .top
        case .bottom: .bottom
        }
    }
    
}

extension Corner {
    
    var alignment: Alignment {
        .init(
            horizontal: horizontalEdge.alignment,
            vertical: verticalEdge.alignment
        )
    }
    
}
