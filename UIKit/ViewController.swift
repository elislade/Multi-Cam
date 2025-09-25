import UIKit
import SwiftUI

class ViewController: UIViewController {
    
    private let provider = VideoProvider()
    
    @IBOutlet weak var backgroundVideoView: PinnedLayerView!
    @IBOutlet weak var pipVideoView: PinnedLayerView!
    
    @IBOutlet weak var pipLeading: NSLayoutConstraint!
    @IBOutlet weak var pipTrailing: NSLayoutConstraint!
    @IBOutlet weak var pipTop: NSLayoutConstraint!
    @IBOutlet weak var pipBottom: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            do {
                try await provider.setup()
                
                backgroundVideoView.set(pinnedLayer: provider.backLayer)
                pipVideoView.set(pinnedLayer: provider.frontLayer)
            } catch {
                print("Provider", error)
            }
        }
        
        pipVideoView.layer.cornerRadius = 10
        pipVideoView.clipsToBounds = true
        pipVideoView.addGestureRecognizer(UIPanGestureRecognizer(
            target: self,
            action: #selector(dragPip)
        ))
    }
    
    @objc private func dragPip(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .changed {
            let translation = recognizer.translation(in: view)
            pipVideoView.transform = CGAffineTransform(translationX: translation.x, y: translation.y)
        } else if recognizer.state == .ended {
            
            let newAlignment = Alignment.nearest(
                to: recognizer.predictedEndLocation(in: view),
                in: view.bounds
            )
            
            updatePipConstraints(to: newAlignment)
            
            let animator = UIViewPropertyAnimator(
                duration: 0,
                timingParameters: UISpringTimingParameters(
                    mass: 1,
                    stiffness: 100,
                    damping: 100,
                    initialVelocity: CGVector(dx: 0.8, dy: 0.8)
                )
            )
            
            animator.addAnimations {
                self.view.layoutIfNeeded()
                self.pipVideoView.transform = .identity
            }
            
            animator.startAnimation()
        }
    }
    
    private func updatePipConstraints(to alignment: Alignment) {
        //Vertical Axis
        pipBottom.priority = alignment.vertical == .top ? .defaultLow : .defaultHigh
        pipTop.priority = alignment.vertical == .top ? .defaultHigh : .defaultLow
        
        //Horizontal Axis
        pipLeading.priority = alignment.horizontal == .leading ? .defaultHigh : .defaultLow
        pipTrailing.priority = alignment.horizontal == .leading ? .defaultLow : .defaultHigh
    }

}

extension UIPanGestureRecognizer {
    
    func predictedEndLocation(in view: UIView?) -> CGPoint {
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
