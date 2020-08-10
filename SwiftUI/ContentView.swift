import SwiftUI

struct ContentView: View {
    
    @State private var provider = VideoProvider()
    @State private var pipAlignment:Alignment = .bottomLeading
    @State private var pipDragOffset:CGSize = .zero
    
    var dragPip: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .global).onChanged({ g in
            self.pipDragOffset = g.translation
        }).onEnded({ g in
            withAnimation(.spring()){
                self.pipDragOffset = .zero
                self.pipAlignment = Alignment.nearest(to: g.predictedEndLocation, in: UIScreen.main.bounds)
            }
        })
    }
    
    var frontVid: some View {
        CALayerView(layer: provider.frontLayer)
            .frame(width: 100, height: 180)
            .background(Color(.pipFill))
            .cornerRadius(10)
            .offset(pipDragOffset)
            .gesture(dragPip)
    }
    
    var body: some View {
        VStack {
            Spacer()
            HStack { Spacer() }
        }
        .background(CALayerView(layer: provider.backLayer).edgesIgnoringSafeArea(.all))
        .background(Image("bg").resizable().edgesIgnoringSafeArea(.all))
        .overlay(frontVid.padding(), alignment: pipAlignment)
        .onAppear(perform: provider.setup)
    }
}

extension UIColor {
    static let myYellow = UIColor(named: "yellow")!
    static let pipFill = UIColor(named: "pipFill")!
}
