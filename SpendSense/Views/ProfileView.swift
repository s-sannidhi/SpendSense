import SwiftUI

struct ProfileView: View {
    @AppStorage("monthlyBudget") private var monthlyBudgetString = ""
    @Environment(\.colorScheme) private var colorScheme
    @State private var showingExportSheet = false
    @StateObject private var userStore = UserStore.shared
    @State private var showingNameEdit = false
    @State private var pdfData: Data?
    
    private var primaryColor: Color {
        colorScheme == .dark ? .mint : .blue
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Sticky Header
            VStack(alignment: .leading, spacing: 12) {
                Text("Profile")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(primaryColor)
                
                Text("Manage your preferences")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding([.horizontal, .top], 20)
            .padding(.bottom, 16)
            .background(Color(.systemBackground))
            
            List {
                Section("Account") {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text("\(userStore.firstName) \(userStore.lastName)")
                            .foregroundColor(.secondary)
                    }
                    .onTapGesture {
                        showingNameEdit = true
                    }
                }
                
                Section("Budget Settings") {
                    HStack {
                        Text("Monthly Budget")
                        Spacer()
                        TextField("Amount", text: $monthlyBudgetString)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section("Data Management") {
                    Button("Export Data") {
                        exportData()
                    }
                    
                    Button("Clear All Data", role: .destructive) {
                        clearAllData()
                    }
                }
                
                Section {
                    Text("Version 1.0.0")
                        .foregroundColor(.secondary)
                }
            }
            .listStyle(.plain)
        }
        .background(Color(.systemBackground).opacity(0.95))
        .sheet(isPresented: $showingExportSheet) {
            if let data = pdfData {
                ShareSheet(items: [data])
            }
        }
        .sheet(isPresented: $showingNameEdit) {
            EditNameView()
        }
    }
    
    private func exportData() {
        // Generate PDF in background
        DispatchQueue.global(qos: .userInitiated).async {
            let data = generatePDF()
            
            DispatchQueue.main.async {
                self.pdfData = data
                self.showingExportSheet = true
            }
        }
    }
    
    private func generatePDF() -> Data {
        let transactions = TransactionStore.shared.transactions
        let goals = GoalsStore.shared.goals
        let userName = "\(UserStore.shared.firstName) \(UserStore.shared.lastName)"
        
        // Create PDF document
        let pdfMetaData = [
            kCGPDFContextCreator: "SpendSense",
            kCGPDFContextAuthor: userName
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4 size
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        let data = renderer.pdfData { context in
            context.beginPage()
            let headerAttributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 28, weight: .bold)
            ]
            let subHeaderAttributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .medium)
            ]
            let titleAttributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .semibold)
            ]
            let textAttributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)
            ]
            
            // Header
            "Financial Report".draw(at: CGPoint(x: 30, y: 30), withAttributes: headerAttributes)
            
            // User Info
            "Prepared for: \(userName)".draw(
                at: CGPoint(x: 30, y: 70),
                withAttributes: subHeaderAttributes
            )
            
            let currentDate = Date().formatted(date: .long, time: .omitted)
            "Generated on: \(currentDate)".draw(
                at: CGPoint(x: 30, y: 95),
                withAttributes: textAttributes
            )
            
            // Summary
            let totalBalance = transactions.reduce(0) { $0 + $1.amount }
            let totalSavingsGoals = goals.reduce(0) { $0 + ($1.targetAmount - $1.currentAmount) }
            
            "Account Summary".draw(at: CGPoint(x: 30, y: 130), withAttributes: titleAttributes)
            "Current Balance: $\(String(format: "%.2f", totalBalance))".draw(
                at: CGPoint(x: 45, y: 155),
                withAttributes: textAttributes
            )
            "Total Savings Goals: $\(String(format: "%.2f", totalSavingsGoals))".draw(
                at: CGPoint(x: 45, y: 175),
                withAttributes: textAttributes
            )
            
            // Transactions
            "Recent Transactions".draw(at: CGPoint(x: 30, y: 210), withAttributes: titleAttributes)
            var y = 235
            for transaction in transactions.sorted(by: { $0.date > $1.date }).prefix(10) {
                let amountString = String(format: "%.2f", abs(transaction.amount))
                let text = "\(dateFormatter.string(from: transaction.date)) - \(transaction.category.name) - \(transaction.note) - $\(amountString)"
                text.draw(at: CGPoint(x: 45, y: y), withAttributes: textAttributes)
                y += 20
            }
            
            // Goals
            "Savings Goals".draw(at: CGPoint(x: 30, y: y + 25), withAttributes: titleAttributes)
            y += 50
            for goal in goals {
                let deadline = goal.deadline.map { dateFormatter.string(from: $0) } ?? "No deadline"
                let targetString = String(format: "%.2f", goal.targetAmount)
                let currentString = String(format: "%.2f", goal.currentAmount)
                let progress = Int((goal.currentAmount / goal.targetAmount) * 100)
                let text = "\(goal.name) - Progress: \(progress)% - Current: $\(currentString) / Target: $\(targetString) - Deadline: \(deadline)"
                text.draw(at: CGPoint(x: 45, y: y), withAttributes: textAttributes)
                y += 20
            }
            
            // Footer
            let footerText = "Generated by SpendSense"
            footerText.draw(
                at: CGPoint(x: pageRect.width - 200, y: pageRect.height - 40),
                withAttributes: textAttributes
            )
        }
        
        return data
    }
    
    private func clearAllData() {
        let defaults = UserDefaults.standard
        let domain = Bundle.main.bundleIdentifier!
        defaults.removePersistentDomain(forName: domain)
        defaults.synchronize()
        
        TransactionStore.shared.clearAll()
        GoalsStore.shared.clearAll()
        monthlyBudgetString = ""
    }
    
    private var monthlyBudget: Double {
        return Double(monthlyBudgetString.replacingOccurrences(of: ",", with: ".")) ?? 0.0
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct EditNameView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var userStore = UserStore.shared
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Your Information") {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                }
            }
            .navigationTitle("Edit Name")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        userStore.saveUserInfo(firstName: firstName, lastName: lastName)
                        dismiss()
                    }
                    .disabled(firstName.isEmpty || lastName.isEmpty)
                }
            }
            .onAppear {
                firstName = userStore.firstName
                lastName = userStore.lastName
            }
        }
    }
} 