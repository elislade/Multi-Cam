import SwiftUI

struct ContentView: View {
    
    @State private var provider = VideoProvider()
    @State private var pipAlignment: Alignment = .bottomLeading
    @State private var pipDragOffset: CGSize = .zero
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: pipAlignment) {
                CALayerView(layer: provider.backLayer)
                    .ignoresSafeArea()
                
                CALayerView(layer: provider.frontLayer)
                    .frame(width: 100, height: 180)
                    .background(Color(.pipFill))
                    .cornerRadius(10)
                    .offset(pipDragOffset)
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .global)
                            .onChanged{ pipDragOffset = $0.translation }
                            .onEnded{ g in
                                withAnimation(.spring()){
                                    pipDragOffset = .zero
                                    pipAlignment = Alignment.nearest(
                                        to: g.predictedEndLocation,
                                        in: proxy.frame(in: .local)
                                    )
                                }
                            }
                    )
                    .padding()
            }
            .background{
                Image(decorative: "bg")
                    .resizable()
                    .ignoresSafeArea()
            }
            .task {
                do {
                    try await provider.setup()
                } catch {
                    print("Session", error)
                }
            }
        }
    }
    
}


#Preview {
    ContentView()
}


extension UIColor {
    static let myYellow = UIColor(named: "yellow")!
    static let pipFill = UIColor(named: "pipFill")!
}
