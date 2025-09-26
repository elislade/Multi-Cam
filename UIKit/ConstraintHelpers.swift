import UIKit

protocol EdgeConstrainable {
    var topAnchor: NSLayoutYAxisAnchor { get }
    var bottomAnchor: NSLayoutYAxisAnchor { get }
    
    var leadingAnchor: NSLayoutXAxisAnchor { get }
    var trailingAnchor: NSLayoutXAxisAnchor { get }
}

extension UIView: EdgeConstrainable {}
extension UILayoutGuide: EdgeConstrainable {}

extension EdgeConstrainable {
    
    @discardableResult func pin<O: EdgeConstrainable>(
        to other: O,
        padding: NSDirectionalEdgeInsets = .zero
    ) -> EdgeConstraints {
        .init(
            top: topAnchor.constraint(equalTo: other.topAnchor, constant: padding.top),
            bottom: bottomAnchor.constraint(equalTo: other.bottomAnchor, constant: -padding.bottom),
            leading: leadingAnchor.constraint(equalTo: other.leadingAnchor, constant: padding.leading),
            trailing: trailingAnchor.constraint(equalTo: other.trailingAnchor, constant: -padding.trailing)
        )
    }
    
}

struct EdgeConstraints {
    
    let top: NSLayoutConstraint
    let bottom: NSLayoutConstraint
    let leading: NSLayoutConstraint
    let trailing: NSLayoutConstraint
    
    func activate() {
        [top, bottom, leading, trailing].forEach{ $0.isActive = true }
    }
    
}

extension EdgeConstraints {
    
    func configure(for corner: Corner){
        //Vertical Axis
        bottom.priority = corner.verticalEdge == .top ? .defaultLow : .defaultHigh
        top.priority = corner.verticalEdge == .top ? .defaultHigh : .defaultLow
        
        //Horizontal Axis
        leading.priority = corner.horizontalEdge == .leading ? .defaultHigh : .defaultLow
        trailing.priority = corner.horizontalEdge == .leading ? .defaultLow : .defaultHigh
    }
    
}

extension NSDirectionalEdgeInsets: @retroactive ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(
            top: CGFloat(value),
            leading: CGFloat(value),
            bottom: CGFloat(value),
            trailing: CGFloat(value)
        )
    }
    
}
