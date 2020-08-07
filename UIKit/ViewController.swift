import UIKit
import SwiftUI

class ViewController: UIViewController {
    
    let provider = VideoProvider()
    
    @IBOutlet weak var backgroundVideoView: PinnedLayerView!
    @IBOutlet weak var pipVideoView: PinnedLayerView!
    
    @IBOutlet weak var pipLeading: NSLayoutConstraint!
    @IBOutlet weak var pipTrailing: NSLayoutConstraint!
    @IBOutlet weak var pipTop: NSLayoutConstraint!
    @IBOutlet weak var pipBottom: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        provider.setup()
        backgroundVideoView.set(pinnedLayer: provider.backLayer)
        pipVideoView.set(pinnedLayer: provider.frontLayer)
        pipVideoView.layer.cornerRadius = 10
        pipVideoView.clipsToBounds = true
        pipVideoView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(dragPip)))
    }
    
    @objc func dragPip(r:UIPanGestureRecognizer){
        if r.state == .changed {
            let t =  r.translation(in: view)
            pipVideoView.transform = CGAffineTransform(translationX: t.x, y: t.y)
        } else if r.state == .ended {
            let alignment = Alignment.nearest(to: r.predictedEndLocation(in: view), in: view.bounds)
            changeConstraints(from: alignment)
            
            let params = UISpringTimingParameters(mass: 1.0, stiffness: 100.0, damping: 100.0, initialVelocity: CGVector(dx: 0.8, dy: 0.8))
            let animator = UIViewPropertyAnimator(duration: 0, timingParameters: params)
            
            animator.addAnimations {
                self.view.layoutIfNeeded()
                self.pipVideoView.transform = .identity
            }
            animator.startAnimation()
        }
    }
    
    func changeConstraints(from alignment:Alignment){
        if alignment.vertical == .top {
            pipBottom.priority = .defaultLow
            pipTop.priority = .defaultHigh
        }
        if alignment.vertical == .bottom {
            pipBottom.priority = .defaultHigh
            pipTop.priority = .defaultLow
        }
        if alignment.horizontal == .leading {
            pipLeading.priority = .defaultHigh
            pipTrailing.priority = .defaultLow
        }
        if alignment.horizontal == .trailing {
            pipLeading.priority = .defaultLow
            pipTrailing.priority = .defaultHigh
        }
    }

}

extension UIPanGestureRecognizer {
    
    func predictedEndLocation(in view:UIView?) -> CGPoint {
        func project(from initialVelocity: CGFloat, with decelerationRate: CGFloat) -> CGFloat {
            (initialVelocity / 1000) * decelerationRate / (1 - decelerationRate)
        }
        
        let point = location(in: view)
        let decelerationRate = UIScrollView.DecelerationRate.normal.rawValue
        let _velocity = velocity(in: view)
        
        return CGPoint(
            x: point.x + project(from: _velocity.x, with: decelerationRate),
            y: point.y + project(from: _velocity.y, with: decelerationRate)
        )
    }
    
}
