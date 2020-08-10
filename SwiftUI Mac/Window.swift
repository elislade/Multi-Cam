import Cocoa
import SwiftUI
import Combine

class WindowRef: NSObject, ObservableObject {
    private let window:NSWindow
    
    @Published private(set) var isFullscreen = false
    @Published private(set) var bounds:CGRect = .zero
    
    init(_ window:NSWindow){
        self.window = window
        super.init()
        self.window.delegate = self
    }
    
    func close(){ window.close() }
    func minimize(){ window.miniaturize(nil) }
    func fullscreen(){ window.toggleFullScreen(nil) }
    
    func update(offset:CGSize){
        let f = window.frame.offsetBy(dx: offset.width, dy: -offset.height / 2)
        window.setFrame(f, display: true)
    }
}

extension WindowRef: NSWindowDelegate {
    
    func windowDidEnterFullScreen(_ notification: Notification) {
        isFullscreen = true
        window.contentView?.layer?.cornerRadius = 0
    }
    
    func windowDidExitFullScreen(_ notification: Notification) {
        isFullscreen = false
        window.contentView?.layer?.cornerRadius = 12
    }
    
    func windowDidResize(_ notification: Notification) {
        if let b = window.contentView?.bounds {
            bounds = b
        }
    }
    
}


struct WindowDraggable: ViewModifier {
    @EnvironmentObject var window:WindowRef
    
    func body(content: Content) -> some View {
        content.gesture(DragGesture(coordinateSpace: .local).onChanged({ g in
            self.window.update(offset: g.translation)
        }))
    }
}


extension View {
    func windowDraggable() -> some View {
        modifier(WindowDraggable())
    }
}
