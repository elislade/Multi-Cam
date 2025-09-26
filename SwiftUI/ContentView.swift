import SwiftUI

struct ContentView: View {
    
    @State private var provider = VideoProvider()
    @State private var pipIsFront = true
    @State private var pipCorner: Corner = .bottomLeading
    @State private var pipDragOffset: CGSize = .zero
    @State private var isSetup = false
    
    @State private var setupError: LocalizedError?
    @State private var showSetupError = false
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: pipCorner.alignment) {
                Color.clear
                
                if isSetup {
                    CALayerView(
                        layer: pipIsFront ? provider.backLayer : provider.frontLayer
                    )
                    .ignoresSafeArea()
                    .zIndex(1)
                    .transition(.opacity.animation(.easeOut))
                    
                    CALayerView(
                        layer: pipIsFront ? provider.frontLayer : provider.backLayer
                    )
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
                                    pipCorner = .nearest(
                                        to: g.predictedEndLocation,
                                        in: proxy.frame(in: .local)
                                    )
                                }
                            }
                            .simultaneously(with: TapGesture().onEnded{
                                pipIsFront.toggle()
                            })
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
                    setupError = error as? LocalizedError
                    showSetupError = true
                }
            }
            .alert("Error", isPresented: $showSetupError){
                Button("Okay"){}
            } message: {
                if let setupError {
                    Text(verbatim: "\(setupError)")
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
