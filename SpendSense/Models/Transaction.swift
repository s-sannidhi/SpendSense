import Foundation

struct Transaction: Identifiable, Codable {
    let id: UUID
    let amount: Double
    let category: Category
    let date: Date
    let note: String
    let isRecurring: Bool
    let recurringInterval: RecurringInterval?
    
    enum RecurringInterval: String, Codable, CaseIterable {
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
        case yearly = "Yearly"
    }
    
    init(id: UUID = UUID(), amount: Double, category: Category, date: Date, note: String, isRecurring: Bool = false, recurringInterval: RecurringInterval? = nil) {
        self.id = id
        self.amount = amount
        self.category = category
        self.date = date
        self.note = note
        self.isRecurring = isRecurring
        self.recurringInterval = recurringInterval
    }
} 