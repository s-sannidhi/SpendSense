import SwiftUI
import Charts

struct DashboardView: View {
    @StateObject private var transactionStore = TransactionStore.shared
    @Environment(\.colorScheme) var colorScheme
    
    // Define our duotone colors
    private var primaryColor: Color {
        colorScheme == .dark ? .mint : .blue
    }
    
    private var secondaryColor: Color {
        colorScheme == .dark ? .mint.opacity(0.2) : .blue.opacity(0.1)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Sticky Header with improved spacing and contrast
            VStack(alignment: .leading, spacing: 12) {
                Text("Your Finances")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(primaryColor)
                
                Text("Track, save, and achieve your goals")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding([.horizontal, .top], 20)
            .padding(.bottom, 16)
            .background(Color(.systemBackground))
            
            // Scrollable Content with improved spacing
            ScrollView {
                VStack(spacing: 24) {  // Increased spacing between sections
                    // Balance Card
                    BalanceCardView(balance: transactionStore.currentBalance)
                        .background(secondaryColor)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                    
                    // Monthly Overview
                    SpendingOverviewView()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                    
                    // Goals Overview (new)
                    GoalsOverviewView()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                    
                    // Upcoming Transactions
                    UpcomingTransactionsView()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                    
                    // Recent Transactions
                    RecentTransactionsView()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .background(Color(.systemBackground).opacity(0.95))
        .scrollContentBackground(.hidden)
        .safeAreaInset(edge: .top) {
            Color.clear.frame(height: 0)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
} 