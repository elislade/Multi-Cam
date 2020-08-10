import SwiftUI

struct TrafficLights: View {
    
    let size:CGFloat = 15
    
    @EnvironmentObject private var w:WindowRef
    @State private var hover = false
    
    enum WindowAction: CaseIterable {
        case close, minimize, fullscreen
    }
    
    func color(for action: WindowAction) -> Color {
        action == .close ? .red : action == .minimize ? .orange : .green
    }
    
    func imgName(for action: WindowAction) -> String {
        action == .close ? "close" : action == .minimize ? "minus" : w.isFullscreen ? "contract" : "expand"
    }
    
    func trigger(for action: WindowAction) {
        if action == .close { w.close() } else
        if action == .minimize { w.minimize() } else
        { w.fullscreen() }
    }
    
    func circle(for act:WindowAction) -> some View {
        ZStack {
            Circle()
            Circle()
                .inset(by: 1)
                .stroke(Color.secondary, lineWidth: hover ? 0 : 2)
            
            if hover {
                Image(imgName(for: act)).opacity(0.5)
                    .transition(AnyTransition.scale(scale: 0.85).combined(with: .opacity))
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 8){
            ForEach(WindowAction.allCases, id: \.self) { action in
                Button(action: { self.trigger(for: action) } ){
                    self.circle(for: action)
                }
                .frame(width: self.size, height: self.size)
                .foregroundColor(self.hover ? self.color(for: action) : .clear)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(4)
        .onHover { h in
            withAnimation(.linear(duration: 0.15)){
                self.hover = h
            }
        }
    }
}

