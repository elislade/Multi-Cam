import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        newWindow(from: ContentView().windowDraggable())
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func newWindow<T:View>(from view:T){
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.closable, .resizable, .borderless, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        
        let contentView = view.environmentObject(WindowRef(window))
        
        window.center()
        window.collectionBehavior = [.fullScreenPrimary]
        //window.setFrameAutosaveName("Main Window")
        window.setContentBorderThickness(0, for: .maxX)
        window.contentView = NSHostingView(rootView: contentView)
        window.contentView?.layer?.borderWidth = 0.2
        window.contentView?.layer?.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        window.contentView?.layer?.cornerRadius = 12
        window.backgroundColor = .clear
        window.makeKeyAndOrderFront(nil)
    }
}

