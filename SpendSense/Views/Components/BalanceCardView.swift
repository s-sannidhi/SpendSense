import SwiftUI

struct BalanceCardView: View {
    let balance: Double
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Current Balance")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("$\(balance, specifier: "%.2f")")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.primary)
            
            HStack(spacing: 24) {
                Button(action: { /* Add Income */ }) {
                    Label("Income", systemImage: "plus.circle.fill")
                        .foregroundColor(.green)
                }
                
                Button(action: { /* Add Expense */ }) {
                    Label("Expense", systemImage: "minus.circle.fill")
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.background)
        .cornerRadius(16)
        .shadow(radius: 2)
    }
} 