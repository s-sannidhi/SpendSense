import SwiftUI

struct UpcomingTransactionsView: View {
    @StateObject private var transactionStore = TransactionStore.shared
    @State private var selectedType: TransactionType = .expense
    @Environment(\.colorScheme) var colorScheme
    
    enum TransactionType: String, CaseIterable {
        case expense = "Expenses"
        case income = "Income"
    }
    
    private var primaryColor: Color {
        colorScheme == .dark ? .mint : .blue
    }
    
    var upcomingTransactions: [Transaction] {
        transactionStore.transactions
            .filter { transaction in
                transaction.isRecurring &&
                (selectedType == .expense ? transaction.amount < 0 : transaction.amount > 0)
            }
            .sorted { $0.date < $1.date }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Upcoming Transactions")
                .font(.headline)
            
            Picker("Type", selection: $selectedType) {
                ForEach(TransactionType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
            
            if upcomingTransactions.isEmpty {
                Text("No upcoming \(selectedType.rawValue.lowercased())")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical)
            } else {
                ForEach(upcomingTransactions) { transaction in
                    HStack {
                        Image(systemName: transaction.category.icon)
                            .font(.title3)
                            .foregroundColor(Color(transaction.category.color))
                            .frame(width: 32, height: 32)
                            .background(Color(transaction.category.color).opacity(0.2))
                            .cornerRadius(8)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(transaction.note)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            HStack {
                                Text(transaction.recurringInterval?.rawValue ?? "")
                                Text("• Next: \(transaction.date.formatted(date: .abbreviated, time: .omitted))")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("$\(abs(transaction.amount), specifier: "%.2f")")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(transaction.amount < 0 ? .red : .green)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(.background)
        .cornerRadius(16)
        .shadow(radius: 2)
    }
} 