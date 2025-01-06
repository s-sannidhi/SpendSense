import SwiftUI

struct SetupView: View {
    @StateObject private var transactionStore = TransactionStore.shared
    @StateObject private var goalsStore = GoalsStore.shared
    @AppStorage("hasCompletedSetup") private var hasCompletedSetup = false
    @State private var currentStep = 0
    @State private var initialBalance = ""
    @State private var showingAddExpense = false
    @State private var recurringTransactions: [Transaction] = []
    @State private var setupGoals: [Goal] = []
    @State private var hasAddedInitialBalance = false
    
    var body: some View {
        NavigationStack {
            Group {
                switch currentStep {
                case 0:
                    WelcomeStepView {
                        withAnimation {
                            currentStep = 1
                        }
                    }
                case 1:
                    NameSetupView {
                        withAnimation {
                            currentStep = 2
                        }
                    }
                case 2:
                    BalanceStepView(balance: $initialBalance) {
                        withAnimation {
                            if !hasAddedInitialBalance,
                               let balance = Double(initialBalance.replacingOccurrences(of: ",", with: ".")) {
                                // Add initial balance as a transaction
                                transactionStore.addTransaction(Transaction(
                                    amount: balance,
                                    category: Category(
                                        name: "Initial Balance",
                                        icon: "dollarsign.circle.fill",
                                        color: "blue",
                                        type: .income
                                    ),
                                    date: Date(),
                                    note: "Initial Balance",
                                    isRecurring: false
                                ))
                                hasAddedInitialBalance = true
                            }
                            currentStep = 3
                        }
                    }
                case 3:
                    RecurringTransactionsStepView(transactions: $recurringTransactions) {
                        // Add all recurring transactions
                        for transaction in recurringTransactions {
                            transactionStore.addTransaction(transaction)
                        }
                        currentStep = 4
                    }
                case 4:
                    SetupGoalsView(goals: $setupGoals) {
                        // Add all goals
                        for goal in setupGoals {
                            goalsStore.addGoal(goal)
                        }
                        hasCompletedSetup = true
                    }
                default:
                    EmptyView()
                }
            }
            .navigationBarBackButtonHidden(true)
            .interactiveDismissDisabled()
        }
    }
}

// Welcome Step
struct WelcomeStepView: View {
    let onContinue: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    private var primaryColor: Color {
        colorScheme == .dark ? .mint : .blue
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(primaryColor)
            
            Text("Welcome to SpendSense")
                .font(.system(size: 32, weight: .bold, design: .rounded))
            
            Text("Let's set up your finances in just a few steps")
                .font(.system(size: 18))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Button(action: onContinue) {
                Text("Get Started")
                    .font(.system(size: 18, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(primaryColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding()
    }
}

// Balance Step
struct BalanceStepView: View {
    @Binding var balance: String
    let onContinue: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    private var primaryColor: Color {
        colorScheme == .dark ? .mint : .blue
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Text("What's your current balance?")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            Text("Enter your current bank balance to get started")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            TextField("0.00", text: $balance)
                .font(.system(size: 40, weight: .medium))
                .multilineTextAlignment(.center)
                .keyboardType(.decimalPad)
            
            Spacer()
            
            Button(action: onContinue) {
                Text("Continue")
                    .font(.system(size: 18, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(primaryColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(balance.isEmpty)
        }
        .padding()
    }
}

// Recurring Expenses Step
struct RecurringTransactionsStepView: View {
    @Binding var transactions: [Transaction]
    let onComplete: () -> Void
    @State private var showingAddTransaction = false
    @State private var transactionType = true // true for expense, false for income
    @Environment(\.colorScheme) var colorScheme
    
    private var primaryColor: Color {
        colorScheme == .dark ? .mint : .blue
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Add Your Regular Transactions")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            Text("Add your recurring bills, subscriptions, and income")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            // Type Selector
            Picker("Type", selection: $transactionType) {
                Text("Expenses").tag(true)
                Text("Income").tag(false)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            if transactions.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 48))
                        .foregroundColor(primaryColor)
                    
                    Text("No recurring transactions yet")
                        .foregroundColor(.secondary)
                        .padding()
                }
            } else {
                List {
                    ForEach(transactions) { transaction in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(transaction.note)
                                    .font(.system(size: 16, weight: .medium))
                                HStack {
                                    Text(transaction.recurringInterval?.rawValue ?? "")
                                    Text("• Next: \(transaction.date.formatted(date: .abbreviated, time: .omitted))")
                                }
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text("$\(abs(transaction.amount), specifier: "%.2f")")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(transaction.amount < 0 ? .red : .green)
                        }
                    }
                    .onDelete { indexSet in
                        transactions.remove(atOffsets: indexSet)
                    }
                }
                .listStyle(.plain)
            }
            
            HStack(spacing: 12) {
                Button(action: { 
                    transactionType = true
                    showingAddTransaction = true 
                }) {
                    Label("Add Expense", systemImage: "minus.circle.fill")
                }
                .buttonStyle(.bordered)
                .tint(.red)
                
                Button(action: { 
                    transactionType = false
                    showingAddTransaction = true 
                }) {
                    Label("Add Income", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.bordered)
                .tint(.green)
            }
            
            HStack(spacing: 16) {
                Button(action: onComplete) {
                    Text("Skip")
                        .font(.system(size: 18, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                }
                
                Button(action: onComplete) {
                    Text("Continue")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(primaryColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
        }
        .padding()
        .sheet(isPresented: $showingAddTransaction) {
            AddTransactionView(
                isRecurringOnly: true,
                isExpense: transactionType,
                isRecurring: true,
                onAdd: { transaction in
                    transactions.append(transaction)
                }
            )
            .interactiveDismissDisabled()
        }
    }
}

struct SetupGoalsView: View {
    @Binding var goals: [Goal]
    let onComplete: () -> Void
    @State private var showingAddGoal = false
    @Environment(\.colorScheme) var colorScheme
    
    private var primaryColor: Color {
        colorScheme == .dark ? .mint : .blue
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Set Your Savings Goals")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            Text("Add goals to help you save for what matters")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if goals.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "target")
                        .font(.system(size: 48))
                        .foregroundColor(primaryColor)
                    
                    Text("No goals added yet")
                        .foregroundColor(.secondary)
                }
                .padding()
            } else {
                List {
                    ForEach(goals) { goal in
                        HStack {
                            Image(systemName: goal.icon)
                                .font(.title2)
                                .foregroundColor(primaryColor)
                                .frame(width: 40, height: 40)
                                .background(primaryColor.opacity(0.1))
                                .cornerRadius(10)
                            
                            VStack(alignment: .leading) {
                                Text(goal.name)
                                    .font(.system(size: 16, weight: .semibold))
                                if let deadline = goal.deadline {
                                    Text(deadline, style: .date)
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            Text("$\(goal.targetAmount, specifier: "%.2f")")
                                .font(.system(size: 16, weight: .medium))
                        }
                    }
                    .onDelete { indexSet in
                        goals.remove(atOffsets: indexSet)
                    }
                }
                .listStyle(.plain)
            }
            
            Button(action: { showingAddGoal = true }) {
                Label("Add Goal", systemImage: "plus.circle.fill")
            }
            .buttonStyle(.bordered)
            .tint(primaryColor)
            
            HStack(spacing: 16) {
                Button(action: onComplete) {
                    Text("Skip")
                        .font(.system(size: 18, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                }
                
                Button(action: onComplete) {
                    Text("Complete Setup")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(primaryColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(goals.isEmpty)
            }
        }
        .padding()
        .sheet(isPresented: $showingAddGoal) {
            AddGoalView { goal in
                goals.append(goal)
            }
            .interactiveDismissDisabled()
        }
    }
} 