import SwiftUI

struct IconPickerView: View {
    @Binding var selectedIcon: String
    
    let icons = [
        "dollarsign.circle.fill",
        "creditcard.fill",
        "house.fill",
        "car.fill",
        "airplane",
        "basket.fill",
        "gift.fill",
        "graduationcap.fill",
        "book.fill",
        "display",
        "gamecontroller",
        "camera.fill",
        "heart.fill",
        "cross.fill",
        "bag.fill",
        "tram.fill"
    ]
    
    let columns = Array(repeating: GridItem(.flexible()), count: 4)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(icons, id: \.self) { icon in
                Image(systemName: icon)
                    .font(.title2)
                    .frame(width: 44, height: 44)
                    .background(selectedIcon == icon ? Color.blue.opacity(0.2) : Color.clear)
                    .cornerRadius(8)
                    .onTapGesture {
                        selectedIcon = icon
                    }
            }
        }
        .padding()
    }
}

#Preview {
    IconPickerView(selectedIcon: .constant("house.fill"))
} 