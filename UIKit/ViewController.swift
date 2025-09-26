import UIKit


class ViewController: UIViewController {
    
    private let provider = VideoProvider()
    
    private lazy var backgroundView: UIImageView = {
        let image = UIImage(named: "bg")
        let view = UIImageView(image: image)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleToFill
        view.backgroundColor = .black
        return view
    }()
    
    private lazy var fullVideoView: PinnedLayerView = {
        let view = PinnedLayerView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var pipIsFront = true
    
    private lazy var pipView: PinnedLayerView = {
        let view = PinnedLayerView()
        view.backgroundColor = .black.withAlphaComponent(0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 100).isActive = true
        view.heightAnchor.constraint(equalToConstant: 180).isActive = true
        view.clipsToBounds = true
        view.layer.cornerRadius = 16
        view.addGestureRecognizer(UIPanGestureRecognizer(
            target: self,
            action: #selector(dragPip)
        ))
        
        view.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(swapPip)
        ))
        
        return view
    }()
    
    private var pipEdgeConstraints: EdgeConstraints!
    
    override func loadView() {
        let content = UIView()
        content.addSubview(backgroundView)
        content.addSubview(fullVideoView)
        content.addSubview(pipView)
        view = content
        setupConstraints()
    }
    
    private func setupConstraints() {
        pipEdgeConstraints = pipView.pin(to: view.safeAreaLayoutGuide, padding: 16)
        pipEdgeConstraints.configure(for: .bottomLeading)
        pipEdgeConstraints.activate()
        
        backgroundView.pin(to: view).activate()
        fullVideoView.pin(to: view).activate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updatePipVisibility(isVisible: false, animated: animated)
        updateBGVisibility(isVisible: false, animated: animated)
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
 
        Task {
            do {
                try await provider.setup()
                fullVideoView.set(pinnedLayer: provider.backLayer)
                pipView.set(pinnedLayer: provider.frontLayer)
                updatePipVisibility(isVisible: true, animated: true)
                updateBGVisibility(isVisible: true, animated: true)
            } catch {
                let alert = UIAlertController(
                    title: "Error",
                    message: "\(error)",
                    preferredStyle: .alert
                )
                alert.addAction(.init(title: "Okay", style: .default))
                present(alert, animated: true)
            }
        }
    }
    
    private func updateBGVisibility(isVisible: Bool, animated: Bool) {
        if animated {
            let animator = UIViewPropertyAnimator(
                duration: 0.6,
                timingParameters: UICubicTimingParameters(animationCurve: .easeOut)
            )
            
            animator.addAnimations {
                self.fullVideoView.alpha = isVisible ? 1 : 0
            }
            
            animator.startAnimation()
        } else {
            self.fullVideoView.alpha = isVisible ? 1 : 0
        }
    }
    
    private func updatePipVisibility(isVisible: Bool, animated: Bool) {
        if animated {
            let animator = UIViewPropertyAnimator(
                duration: 0,
                timingParameters: UISpringTimingParameters(
                    mass: 1,
                    stiffness: 50,
                    damping: 8,
                    initialVelocity: CGVector(dx: 2, dy: 2)
                )
            )
            
            animator.addAnimations {
                self.pipView.transform = isVisible ? .identity : CGAffineTransform(scaleX: 0, y: 0)
            }
            
            animator.startAnimation()
        } else {
            self.pipView.transform = isVisible ? .identity : CGAffineTransform(scaleX: 0, y: 0)
        }
    }
    
    @objc private func dragPip(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .changed {
            let translation = recognizer.translation(in: view)
            pipView.transform = CGAffineTransform(translationX: translation.x, y: translation.y)
        } else if recognizer.state == .ended {
            
            let newAlignment = Corner.nearest(
                to: recognizer.predictedEndLocation(in: view),
                in: view.bounds
            )
            
            pipEdgeConstraints.configure(for: newAlignment)
            
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
                self.pipView.transform = .identity
            }
            
            animator.startAnimation()
        }
    }

    @objc private func swapPip() {
        fullVideoView.set(pinnedLayer: pipIsFront ? provider.frontLayer : provider.backLayer)
        pipView.set(pinnedLayer: pipIsFront ? provider.backLayer : provider.frontLayer)
        pipIsFront.toggle()
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


@available(iOS 17.0, *)
#Preview{
    ViewController(nibName: nil, bundle: nil)
}
