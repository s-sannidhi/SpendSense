import Foundation

struct Goal: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var targetAmount: Double
    var currentAmount: Double
    var deadline: Date?
    var icon: String
    var amazonProduct: AmazonProductInfo?
    
    struct AmazonProductInfo: Codable {
        let title: String
        let initialPrice: Double
        let currentPrice: Double
        let productUrl: String
        let lastUpdated: Date
    }
} 