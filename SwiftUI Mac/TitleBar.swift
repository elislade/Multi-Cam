import SwiftUI

struct TitleBar: View {
    
    @Binding var fullVideo:Bool
    @State private var headerHover = false
    
    var body: some View {
       HStack(spacing: 15) {
            TrafficLights()
            if headerHover {
                Text("Video Chat".uppercased())
                    .font(.headline).fontWeight(.black).italic()
                    .lineLimit(1)
            }
            Spacer()
            Button(action: { self.fullVideo.toggle()}){
                Text("\(fullVideo ? "Pip" : "Full") Video".uppercased()).italic()
            }
        }
        .font(.system(size: 12, weight: .black, design: .default))
        .foregroundColor(.black)
        .padding()
        .overlay(ZStack{ headerHover ? Divider() : nil }, alignment: .bottom)
        .onHover{ h in withAnimation { self.headerHover = h } }
    }
}
