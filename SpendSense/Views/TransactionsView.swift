import SwiftUI

struct TransactionsView: View {
    @StateObject private var transactionStore = TransactionStore.shared
    @State private var searchText = ""
    @State private var selectedFilter: TransactionFilter = .all
    @Environment(\.colorScheme) var colorScheme
    
    private var primaryColor: Color {
        colorScheme == .dark ? .mint : .blue
    }
    
    private var secondaryColor: Color {
        colorScheme == .dark ? .mint.opacity(0.2) : .blue.opacity(0.1)
    }
    
    enum TransactionFilter: String, CaseIterable {
        case all = "All"
        case income = "Income"
        case expense = "Expense"
    }
    
    var filteredTransactions: [Transaction] {
        let allTransactions = transactionStore.effectiveTransactions.sorted { $0.date > $1.date }
        let searchResults = searchText.isEmpty ? allTransactions : allTransactions.filter {
            $0.note.localizedCaseInsensitiveContains(searchText) ||
            $0.category.name.localizedCaseInsensitiveContains(searchText)
        }
        
        switch selectedFilter {
        case .all:
            return searchResults
        case .income:
            return searchResults.filter { $0.amount > 0 }
        case .expense:
            return searchResults.filter { $0.amount < 0 }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Sticky Header
            VStack(alignment: .leading, spacing: 12) {
                Text("Transactions")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(primaryColor)
                
                Text("Track your spending and income")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding([.horizontal, .top], 20)
            .padding(.bottom, 16)
            .background(Color(.systemBackground))
            
            // Rest of the content
            VStack(spacing: 0) {
                // Filter Picker
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(TransactionFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                List {
                    ForEach(filteredTransactions) { transaction in
                        TransactionRowView(transaction: transaction)
                            .listRowBackground(Color(.systemBackground))
                            .listRowSeparator(.hidden)
                            .padding(.vertical, 4)
                    }
                }
                .listStyle(.plain)
            }
        }
        .background(Color(.systemBackground).opacity(0.95))
        .searchable(text: $searchText, prompt: "Search transactions")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                AddTransactionButton()
            }
        }
    }
} 