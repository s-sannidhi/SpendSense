import Foundation

extension Transaction {
    static var placeholder: Transaction {
        Transaction(
            amount: -25.99,
            category: Category.defaultCategories[0],
            date: Date(),
            note: "Lunch at Cafe",
            isRecurring: false
        )
    }
} 