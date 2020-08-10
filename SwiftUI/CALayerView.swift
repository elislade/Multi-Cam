import SwiftUI

struct CALayerView: UIViewRepresentable {
    
    let layer:CALayer
    
    func makeUIView(context: Context) -> PinnedLayerView {
        let v = PinnedLayerView()
        v.set(pinnedLayer: layer)
        return v
    }
    
    func updateUIView(_ uiView: PinnedLayerView, context: Context) {}
}
