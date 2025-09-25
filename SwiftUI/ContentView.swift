import SwiftUI

struct ContentView: View {
    
    @State private var provider = VideoProvider()
    @State private var pipAlignment: Alignment = .bottomLeading
    @State private var pipDragOffset: CGSize = .zero
    @State private var isSetup = false
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: pipAlignment) {
                Color.clear
                
                if isSetup {
                    CALayerView(layer: provider.backLayer)
                        .ignoresSafeArea()
                        .zIndex(1)
                        .transition(.opacity.animation(.easeOut))
                    
                    CALayerView(layer: provider.frontLayer)
                        .frame(width: 100, height: 180)
                        .background(Color(.pipFill))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .zIndex(2)
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
                        .transition(.scale.animation(.bouncy(extraBounce: 0.2)))
                }
            }
            .background{
                Image(decorative: "bg")
                    .resizable()
                    .ignoresSafeArea()
            }
            .task {
                do {
                    try await provider.setup()
                    isSetup = true
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
