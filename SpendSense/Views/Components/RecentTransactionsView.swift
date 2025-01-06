import SwiftUI

struct RecentTransactionsView: View {
    @StateObject private var transactionStore = TransactionStore.shared
    
    var recentTransactions: [Transaction] {
        Array(transactionStore.transactions
            .filter { !$0.isRecurring }
            .sorted { $0.date > $1.date }
            .prefix(3))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Transactions")
                    .font(.headline)
                Spacer()
                NavigationLink("See All") {
                    TransactionsView()
                }
                .font(.subheadline)
            }
            
            if recentTransactions.isEmpty {
                Text("No transactions yet")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical)
            } else {
                ForEach(recentTransactions) { transaction in
                    TransactionRowView(transaction: transaction)
                }
            }
        }
        .padding()
        .background(.background)
        .cornerRadius(16)
        .shadow(radius: 2)
    }
}

struct TransactionRowView: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            Image(systemName: transaction.category.icon)
                .font(.title2)
                .foregroundColor(Color(transaction.category.color))
                .frame(width: 44, height: 44)
                .background(Color(transaction.category.color).opacity(0.2))
                .cornerRadius(12)
            
            VStack(alignment: .leading) {
                Text(transaction.category.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(transaction.note)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("$\(transaction.amount, specifier: "%.2f")")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(transaction.amount < 0 ? .red : .green)
        }
    }
} 