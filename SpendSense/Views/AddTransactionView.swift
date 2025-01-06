import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var amount: String = ""
    @State private var note: String = ""
    @State private var date = Date()
    @State private var isExpense: Bool
    @State private var isRecurring: Bool
    @State private var recurringInterval: Transaction.RecurringInterval = .monthly
    @State private var selectedCategory: Category = Category.defaultCategories[0]
    var isRecurringOnly: Bool = false
    var onAdd: ((Transaction) -> Void)? = nil
    
    init(
        isRecurringOnly: Bool = false,
        isExpense: Bool = true,
        isRecurring: Bool = false,
        onAdd: ((Transaction) -> Void)? = nil
    ) {
        self.isRecurringOnly = isRecurringOnly
        self._isExpense = State(initialValue: isExpense)
        self._isRecurring = State(initialValue: isRecurring)
        self.onAdd = onAdd
        self._selectedCategory = State(initialValue: isExpense ? Category.expenseCategories[0] : Category.incomeCategories[0])
    }
    
    private var isValid: Bool {
        guard let _ = Double(amount.replacingOccurrences(of: ",", with: ".")) else {
            return false
        }
        return !amount.isEmpty && !note.isEmpty
    }
    
    var availableCategories: [Category] {
        isExpense ? Category.expenseCategories : Category.incomeCategories
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Amount Section
                Section {
                    HStack {
                        Text(isExpense ? "-" : "+")
                        #if os(iOS)
                        TextField("Amount", text: $amount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        #else
                        TextField("Amount", text: $amount)
                            .multilineTextAlignment(.trailing)
                        #endif
                    }
                    
                    Picker("Type", selection: $isExpense) {
                        Text("Expense").tag(true)
                        Text("Income").tag(false)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: isExpense) { newValue in
                        // Update selected category when switching between income/expense
                        selectedCategory = newValue ? Category.expenseCategories[0] : Category.incomeCategories[0]
                    }
                }
                
                // Details Section
                Section {
                    TextField("Note", text: $note)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(availableCategories) { category in
                            Label(category.name, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                }
                
                // Recurring Section
                Section {
                    if !isRecurringOnly {
                        Toggle("Recurring Transaction", isOn: $isRecurring)
                    } else {
                        let _ = { isRecurring = true }()
                    }
                    
                    if isRecurring {
                        Picker("Repeat", selection: $recurringInterval) {
                            ForEach(Transaction.RecurringInterval.allCases, id: \.self) { interval in
                                Text(interval.rawValue).tag(interval)
                            }
                        }
                    }
                }
            }
            .navigationTitle(isRecurringOnly ? "Add Recurring Expense" : "Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        saveTransaction()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
    
    private func saveTransaction() {
        guard let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")),
              !amount.isEmpty else { return }
        
        let finalAmount = isExpense ? -amountValue : amountValue
        
        let transaction = Transaction(
            amount: finalAmount,
            category: selectedCategory,
            date: date,
            note: note,
            isRecurring: isRecurring,
            recurringInterval: isRecurring ? recurringInterval : nil
        )
        
        if let onAdd = onAdd {
            onAdd(transaction)
        } else {
            TransactionStore.shared.addTransaction(transaction)
        }
        
        dismiss()
    }
} 