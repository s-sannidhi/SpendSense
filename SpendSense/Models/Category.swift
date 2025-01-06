import Foundation
import SwiftUI

struct Category: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var icon: String
    var color: String
    var type: TransactionType
    
    enum TransactionType: String, Codable {
        case expense
        case income
    }
    
    static let defaultCategories: [Category] = [
        // Income Categories
        Category(name: "Salary", icon: "dollarsign.circle.fill", color: "green", type: .income),
        Category(name: "Freelance", icon: "briefcase.fill", color: "blue", type: .income),
        Category(name: "Investments", icon: "chart.line.uptrend.xyaxis", color: "purple", type: .income),
        Category(name: "Allowance", icon: "gift.fill", color: "pink", type: .income),
        Category(name: "Part-time Job", icon: "clock.fill", color: "orange", type: .income),
        Category(name: "Financial Aid", icon: "graduationcap.fill", color: "blue", type: .income),
        
        // Expense Categories
        Category(name: "Food", icon: "fork.knife", color: "red", type: .expense),
        Category(name: "Rent", icon: "house.fill", color: "blue", type: .expense),
        Category(name: "Entertainment", icon: "tv.fill", color: "purple", type: .expense),
        Category(name: "Textbooks", icon: "book.fill", color: "brown", type: .expense),
        Category(name: "Transportation", icon: "car.fill", color: "green", type: .expense),
        Category(name: "Utilities", icon: "bolt.fill", color: "yellow", type: .expense),
        Category(name: "Groceries", icon: "cart.fill", color: "orange", type: .expense),
        Category(name: "Healthcare", icon: "cross.fill", color: "red", type: .expense),
        Category(name: "Shopping", icon: "bag.fill", color: "pink", type: .expense),
        Category(name: "Subscriptions", icon: "repeat.circle.fill", color: "purple", type: .expense)
    ]
    
    static var incomeCategories: [Category] {
        defaultCategories.filter { $0.type == .income }
    }
    
    static var expenseCategories: [Category] {
        defaultCategories.filter { $0.type == .expense }
    }
} 