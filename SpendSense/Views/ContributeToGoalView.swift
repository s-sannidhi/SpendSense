import SwiftUI

struct ContributeToGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var goalsStore = GoalsStore.shared
    let goal: Goal
    @State private var amount: String = ""
    @State private var note: String = ""
    @State private var date = Date()
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .center, spacing: 8) {
                        Text(goal.name)
                            .font(.headline)
                        
                        ProgressView(value: goal.currentAmount, total: goal.targetAmount)
                            .tint(.blue)
                        
                        HStack {
                            Text("$\(goal.currentAmount, specifier: "%.2f")")
                            Text("of")
                            Text("$\(goal.targetAmount, specifier: "%.2f")")
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                }
                
                Section("Contribution Details") {
                    HStack {
                        Text("Amount")
                        Spacer()
                        #if os(iOS)
                        TextField("Amount", text: $amount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        #else
                        TextField("Amount", text: $amount)
                            .multilineTextAlignment(.trailing)
                        #endif
                    }
                    
                    TextField("Note", text: $note)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                
                if let remaining = remainingToGoal, remaining > 0 {
                    Section {
                        Text("$\(remaining, specifier: "%.2f") remaining to reach goal")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Contribute to Goal")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveContribution() }
                }
            }
        }
    }
    
    private var remainingToGoal: Double? {
        guard let contributionAmount = Double(amount.replacingOccurrences(of: ",", with: ".")) else {
            return goal.targetAmount - goal.currentAmount
        }
        return goal.targetAmount - (goal.currentAmount + contributionAmount)
    }
    
    private func saveContribution() {
        guard let contributionAmount = Double(amount.replacingOccurrences(of: ",", with: ".")),
              contributionAmount > 0 else { return }
        
        // Add the contribution to the goal
        goalsStore.contributeToGoal(goal, amount: contributionAmount)
        
        // Create a transaction for this contribution
        let transaction = Transaction(
            amount: -contributionAmount,  // Negative because it's an expense
            category: Category(
                name: "Goal: \(goal.name)",
                icon: goal.icon,
                color: "blue",
                type: .expense
            ),
            date: date,
            note: note.isEmpty ? "Contribution to \(goal.name)" : note,
            isRecurring: false
        )
        
        // Save the transaction
        TransactionStore.shared.addTransaction(transaction)
        
        dismiss()
    }
} 