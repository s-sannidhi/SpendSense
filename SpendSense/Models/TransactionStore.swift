import Foundation

class TransactionStore: ObservableObject {
    static let shared = TransactionStore()
    
    @Published private(set) var transactions: [Transaction] = []
    private let defaults = UserDefaults.standard
    private let transactionsKey = "savedTransactions"
    
    init() {
        loadTransactions()
    }
    
    var effectiveTransactions: [Transaction] {
        let currentDate = Date()
        return transactions.flatMap { transaction -> [Transaction] in
            if transaction.isRecurring, let interval = transaction.recurringInterval {
                // For recurring transactions, only include instances up to current date
                var instances: [Transaction] = []
                var date = transaction.date
                
                while date <= currentDate {
                    instances.append(Transaction(
                        amount: transaction.amount,
                        category: transaction.category,
                        date: date,
                        note: transaction.note,
                        isRecurring: true,
                        recurringInterval: interval
                    ))
                    
                    // Calculate next occurrence
                    switch interval {
                    case .daily:
                        date = Calendar.current.date(byAdding: .day, value: 1, to: date) ?? date
                    case .weekly:
                        date = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: date) ?? date
                    case .monthly:
                        date = Calendar.current.date(byAdding: .month, value: 1, to: date) ?? date
                    case .yearly:
                        date = Calendar.current.date(byAdding: .year, value: 1, to: date) ?? date
                    }
                }
                return instances
            } else {
                return [transaction]
            }
        }
    }
    
    var currentBalance: Double {
        effectiveTransactions.reduce(0) { $0 + $1.amount }
    }
    
    func addTransaction(_ transaction: Transaction) {
        transactions.append(transaction)
        saveTransactions()
    }
    
    func deleteTransactions(at offsets: IndexSet) {
        transactions.remove(atOffsets: offsets)
        saveTransactions()
    }
    
    private func loadTransactions() {
        guard let data = defaults.data(forKey: transactionsKey),
              let savedTransactions = try? JSONDecoder().decode([Transaction].self, from: data) else {
            return
        }
        transactions = savedTransactions
    }
    
    private func saveTransactions() {
        guard let data = try? JSONEncoder().encode(transactions) else { return }
        defaults.set(data, forKey: transactionsKey)
    }
    
    func clearAll() {
        transactions = []
        saveTransactions()
    }
    
    func getUpcomingTransactions(limit: Int = 5) -> [Transaction] {
        let calendar = Calendar.current
        let currentDate = Date()
        let futureDate = calendar.date(byAdding: .month, value: 3, to: currentDate) ?? currentDate
        
        let upcomingTransactions = transactions
            .filter { $0.isRecurring && $0.amount < 0 } // Only recurring expenses
            .flatMap { transaction -> [Transaction] in
                guard let interval = transaction.recurringInterval else { return [] }
                
                var instances: [Transaction] = []
                var date = transaction.date
                
                // Find the next occurrence after current date
                while date <= currentDate {
                    switch interval {
                    case .daily:
                        date = calendar.date(byAdding: .day, value: 1, to: date) ?? date
                    case .weekly:
                        date = calendar.date(byAdding: .weekOfYear, value: 1, to: date) ?? date
                    case .monthly:
                        date = calendar.date(byAdding: .month, value: 1, to: date) ?? date
                    case .yearly:
                        date = calendar.date(byAdding: .year, value: 1, to: date) ?? date
                    }
                }
                
                // Add future occurrences until futureDate
                while date <= futureDate {
                    let instance = Transaction(
                        amount: transaction.amount,
                        category: transaction.category,
                        date: date,
                        note: transaction.note,
                        isRecurring: true,
                        recurringInterval: interval
                    )
                    instances.append(instance)
                    
                    switch interval {
                    case .daily:
                        date = calendar.date(byAdding: .day, value: 1, to: date) ?? date
                    case .weekly:
                        date = calendar.date(byAdding: .weekOfYear, value: 1, to: date) ?? date
                    case .monthly:
                        date = calendar.date(byAdding: .month, value: 1, to: date) ?? date
                    case .yearly:
                        date = calendar.date(byAdding: .year, value: 1, to: date) ?? date
                    }
                }
                
                return instances
            }
        
        return Array(upcomingTransactions
            .sorted { $0.date < $1.date }
            .prefix(limit))
    }
} 