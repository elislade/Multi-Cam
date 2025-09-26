import UIKit


final class PinnedLayerView: UIView {
    
    private var pinLayer = CALayer()
    
    func set(pinnedLayer: CALayer) {
        DispatchQueue.main.async {
            CATransaction.begin()
            CATransaction.setAnimationDuration(0)
            self.layer.sublayers?.removeAll()
            self.pinLayer = pinnedLayer
            self.layer.addSublayer(pinnedLayer)
            CATransaction.commit()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setAnimationDuration(0)
        pinLayer.frame = bounds
        CATransaction.commit()
    }
    
}
