import SwiftUI

struct CALayerView: NSViewRepresentable {
    
    let layer:CALayer
    
    func makeNSView(context: Context) -> NSView {
        let v = NSView()
        v.layer = layer
        return v
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
}
