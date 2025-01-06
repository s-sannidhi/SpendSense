import SwiftUI

extension Color {
    init(stringColor: String) {
        switch stringColor.lowercased() {
        case "red": self = .red
        case "blue": self = .blue
        case "green": self = .green
        case "yellow": self = .yellow
        case "purple": self = .purple
        case "brown": self = .brown
        default: self = .primary
        }
    }
} 