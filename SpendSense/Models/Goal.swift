import Foundation

struct Goal: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var targetAmount: Double
    var currentAmount: Double
    var deadline: Date?
    var icon: String
} 