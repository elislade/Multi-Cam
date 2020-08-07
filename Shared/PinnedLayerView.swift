import UIKit

class PinnedLayerView: UIView {
    private var pinLayer = CALayer()
    
    func set(pinnedLayer:CALayer) {
        DispatchQueue.main.async {
            self.pinLayer.removeFromSuperlayer()
            self.pinLayer = pinnedLayer
            self.layer.addSublayer(pinnedLayer)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.setAnimationDuration(0)
        pinLayer.frame = bounds
        CATransaction.commit()
    }
}
