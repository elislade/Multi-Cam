import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject private var w:WindowRef
    
    @State private var provider = VideoProvider()
    @State private var pipAlignment:Alignment = .bottomLeading
    @State private var pipDragOffset:CGSize = .zero
    @State private var fullVideo = false
    
    var dragPip: some Gesture {
        DragGesture(minimumDistance: 0).onChanged({ g in
            self.pipDragOffset = g.translation
        }).onEnded({ g in
            withAnimation(.spring()){
                self.pipDragOffset = .zero
                self.pipAlignment = Alignment.nearest(to: g.predictedEndLocation, in: self.w.bounds)
            }
        })
    }
    
    var frontVid: some View {
        Group{
            if !fullVideo{
                CALayerView(layer: provider.layer)
            } else {
                Color.clear
            }
        }
        .frame(width: 200, height: 140)
        .background(Color(.pipFill))
        .cornerRadius(6)
        .scaleEffect(x: -1, y: 1)
        .offset(pipDragOffset)
        .gesture(dragPip)
    }
    
    var body: some View {
        VStack(spacing:0) {
            TitleBar(fullVideo: $fullVideo)
            VStack {
                Spacer()
                HStack{ Spacer() }
            }.overlay(frontVid.padding(8), alignment: pipAlignment)
        }
        .background(fullVideo ? CALayerView(layer: provider.layer).scaleEffect(x: -1, y: 1) : nil)
        .background(Image("bg").resizable())
        .onAppear(perform: provider.setup)
    }
}

extension NSColor {
    static let myYellow = NSColor(named: "yellow")!
    static let pipFill = NSColor(named: "pipFill")!
}
