import SwiftUI

struct ProfileView: View {
    @AppStorage("monthlyBudget") private var monthlyBudgetString = ""
    @Environment(\.colorScheme) private var colorScheme
    @State private var showingExportSheet = false
    
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
            ShareSheet(items: [generatePDF()])
        }
    }
    
    private func exportData() {
        showingExportSheet = true
    }
    
    private func generatePDF() -> URL {
        let transactions = TransactionStore.shared.transactions
        let goals = GoalsStore.shared.goals
        
        // Create PDF document
        let pdfMetaData = [
            kCGPDFContextCreator: "SpendSense",
            kCGPDFContextAuthor: "SpendSense User"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4 size
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("SpendSense_Export_\(Date().formatted(date: .numeric, time: .omitted)).pdf")
        
        try? renderer.writePDF(to: url) { context in
            context.beginPage()
            let attributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24, weight: .bold)
            ]
            let titleAttributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .semibold)
            ]
            let textAttributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)
            ]
            
            // Title
            "SpendSense Financial Report".draw(at: CGPoint(x: 30, y: 30), withAttributes: attributes)
            "Generated on \(Date().formatted(date: .long, time: .omitted))".draw(
                at: CGPoint(x: 30, y: 60),
                withAttributes: textAttributes
            )
            
            // Transactions
            "Transactions".draw(at: CGPoint(x: 30, y: 100), withAttributes: titleAttributes)
            var y = 130
            for transaction in transactions {
                let amountString = String(format: "%.2f", abs(transaction.amount))
                let text = "\(dateFormatter.string(from: transaction.date)) - \(transaction.category.name) - \(transaction.note) - $\(amountString)"
                text.draw(at: CGPoint(x: 30, y: y), withAttributes: textAttributes)
                y += 20
            }
            
            // Goals
            "Savings Goals".draw(at: CGPoint(x: 30, y: y + 20), withAttributes: titleAttributes)
            y += 50
            for goal in goals {
                let deadline = goal.deadline.map { dateFormatter.string(from: $0) } ?? "No deadline"
                let targetString = String(format: "%.2f", goal.targetAmount)
                let currentString = String(format: "%.2f", goal.currentAmount)
                let text = "\(goal.name) - Target: $\(targetString) - Current: $\(currentString) - Deadline: \(deadline)"
                text.draw(at: CGPoint(x: 30, y: y), withAttributes: textAttributes)
                y += 20
            }
        }
        
        return url
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
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
} 