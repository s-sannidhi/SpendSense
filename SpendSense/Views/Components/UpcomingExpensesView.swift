import SwiftUI

struct UpcomingExpensesView: View {
    @StateObject private var transactionStore = TransactionStore.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Upcoming Expenses")
                .font(.headline)
            
            if transactionStore.getUpcomingTransactions().isEmpty {
                Text("No upcoming recurring expenses")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical)
            } else {
                ForEach(transactionStore.getUpcomingTransactions()) { transaction in
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
                            Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("$\(abs(transaction.amount), specifier: "%.2f")")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
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