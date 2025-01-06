import SwiftUI
import Charts

struct SpendingOverviewView: View {
    @StateObject private var transactionStore = TransactionStore.shared
    @State private var selectedTimeFrame: TimeFrame = .week
    
    enum TimeFrame: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    var filteredTransactions: [Transaction] {
        let calendar = Calendar.current
        let now = Date()
        
        return transactionStore.transactions.filter { transaction in
            switch selectedTimeFrame {
            case .week:
                return calendar.isDate(transaction.date, equalTo: now, toGranularity: .weekOfYear)
            case .month:
                return calendar.isDate(transaction.date, equalTo: now, toGranularity: .month)
            case .year:
                return calendar.isDate(transaction.date, equalTo: now, toGranularity: .year)
            }
        }
    }
    
    var chartData: [(category: String, amount: Double)] {
        var categoryTotals: [String: Double] = [:]
        
        for transaction in filteredTransactions {
            if transaction.amount < 0 { // Only consider expenses
                let amount = abs(transaction.amount)
                categoryTotals[transaction.category.name, default: 0] += amount
            }
        }
        
        return categoryTotals.map { ($0.key, $0.value) }
            .sorted { $0.amount > $1.amount }
    }
    
    var totalSpending: Double {
        filteredTransactions.filter { $0.amount < 0 }.reduce(0) { $0 + abs($1.amount) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Spending Overview")
                .font(.headline)
            
            Picker("Time Frame", selection: $selectedTimeFrame) {
                ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                    Text(timeFrame.rawValue).tag(timeFrame)
                }
            }
            .pickerStyle(.segmented)
            
            if chartData.isEmpty {
                Text("No expenses in this period")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical)
            } else {
                if #available(iOS 16.0, *) {
                    Chart(chartData, id: \.category) { item in
                        SectorMark(
                            angle: .value("Amount", item.amount),
                            innerRadius: .ratio(0.618),
                            angularInset: 1.5
                        )
                        .cornerRadius(3)
                        .foregroundStyle(by: .value("Category", item.category))
                    }
                    .frame(height: 200)
                } else {
                    // Fallback for iOS 15
                    ForEach(chartData, id: \.category) { item in
                        HStack {
                            Text(item.category)
                            Spacer()
                            Text("$\(item.amount, specifier: "%.2f")")
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            
            // Total spending
            HStack {
                Text("Total Spending")
                    .fontWeight(.medium)
                Spacer()
                Text("$\(totalSpending, specifier: "%.2f")")
                    .foregroundColor(.red)
                    .fontWeight(.bold)
            }
            .padding(.top)
        }
        .padding()
        .background(.background)
        .cornerRadius(16)
        .shadow(radius: 2)
    }
} 