import SwiftUI

struct AddGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var targetAmount = ""
    @State private var deadline: Date = Date().addingTimeInterval(86400 * 30) // 30 days from now
    @State private var hasDeadline = false
    @State private var selectedIcon = "target"
    @State private var showingProductSearch = false
    @State private var selectedProduct: AmazonProduct?
    var onAdd: ((Goal) -> Void)?
    
    private let icons = [
        "star.fill", "car.fill", "house.fill", "graduationcap.fill",
        "airplane", "laptop", "gamecontroller.fill", "camera.fill"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Goal Details") {
                    TextField("Goal Name", text: $name)
                    
                    HStack {
                        Text("Target Amount")
                        Spacer()
                        #if os(iOS)
                        TextField("Amount", text: $targetAmount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        #else
                        TextField("Amount", text: $targetAmount)
                            .multilineTextAlignment(.trailing)
                        #endif
                    }
                    
                    Button(action: { showingProductSearch = true }) {
                        HStack {
                            Image(systemName: "cart.fill")
                            Text("Search Amazon Products")
                        }
                    }
                    
                    if let product = selectedProduct {
                        ProductSummaryView(product: product)
                    }
                }
                
                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4)) {
                        ForEach(icons, id: \.self) { icon in
                            Image(systemName: icon)
                                .font(.title2)
                                .frame(width: 44, height: 44)
                                .background(selectedIcon == icon ? Color.blue.opacity(0.2) : Color.clear)
                                .cornerRadius(8)
                                .onTapGesture {
                                    selectedIcon = icon
                                }
                        }
                    }
                }
                
                Section {
                    Toggle("Set Deadline", isOn: $hasDeadline)
                    
                    if hasDeadline {
                        DatePicker("Deadline", selection: $deadline, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("Add Goal")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveGoal() }
                }
            }
            .sheet(isPresented: $showingProductSearch) {
                AmazonProductSearchView { product in
                    selectedProduct = product
                    name = product.title
                    targetAmount = String(format: "%.2f", product.currentPrice)
                }
            }
        }
    }
    
    private func saveGoal() {
        guard let amount = Double(targetAmount.replacingOccurrences(of: ",", with: ".")),
              !name.isEmpty else { return }
        
        let amazonProductInfo = selectedProduct.map { product in
            Goal.AmazonProductInfo(
                title: product.title,
                initialPrice: product.price,
                currentPrice: product.currentPrice,
                productUrl: product.productUrl,
                lastUpdated: product.lastUpdated
            )
        }
        
        let goal = Goal(
            name: name,
            targetAmount: amount,
            currentAmount: 0,
            deadline: hasDeadline ? deadline : nil,
            icon: selectedIcon,
            amazonProduct: amazonProductInfo
        )
        
        if let onAdd = onAdd {
            onAdd(goal)
        } else {
            GoalsStore.shared.addGoal(goal)
        }
        
        dismiss()
    }
}

struct ProductSummaryView: View {
    let product: AmazonProduct
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Product Details")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: "gift.fill")
                    .frame(width: 40, height: 40)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(6)
                
                VStack(alignment: .leading) {
                    Text(product.title)
                        .font(.footnote)
                        .lineLimit(1)
                    
                    Text("Current Price: $\(product.currentPrice, specifier: "%.2f")")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            
            // Simple price history chart could be added here
            
            Link("View on Amazon", destination: URL(string: product.productUrl)!)
                .font(.caption)
        }
        .padding(.vertical, 8)
    }
} 