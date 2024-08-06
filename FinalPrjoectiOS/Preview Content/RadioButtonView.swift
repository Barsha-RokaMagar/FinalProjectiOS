import SwiftUI

struct RadioButtonView: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                .onTapGesture {
                    action()
                }
            Text(text)
                .onTapGesture {
                    action()
                }
        }
        .padding()
        .background(isSelected ? Color.gray.opacity(0.2) : Color.clear)
        .cornerRadius(10)
    }
}

struct RadioButtonView_Previews: PreviewProvider {
    @State static var isSelected = false
    static var previews: some View {
        RadioButtonView(text: "Example", isSelected: isSelected) {
            isSelected.toggle()
        }
    }
}
