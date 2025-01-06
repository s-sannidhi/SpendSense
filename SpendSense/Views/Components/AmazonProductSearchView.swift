import SwiftUI

struct AmazonProduct: Identifiable, Codable {
    let id = UUID()
    let title: String
    let price: Double
    let imageUrl: String
    let productUrl: String
    var currentPrice: Double
    var priceHistory: [Double]
    var lastUpdated: Date
}

struct AmazonProductSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var searchResults: [AmazonProduct] = []
    @State private var isLoading = false
    @State private var error: Error?
    var onSelect: (AmazonProduct) -> Void
    
    var body: some View {
        NavigationStack {
            VStack {
                SearchBar(text: $searchText, onSubmit: performSearch)
                
                if isLoading {
                    ProgressView()
                        .padding()
                } else if let error = error {
                    ContentUnavailableView(
                        "Search Failed",
                        systemImage: "exclamationmark.triangle",
                        description: Text(error.localizedDescription)
                    )
                } else if searchResults.isEmpty {
                    ContentUnavailableView(
                        "Search Amazon Products",
                        systemImage: "magnifyingglass",
                        description: Text("Search for products to create a savings goal")
                    )
                } else {
                    List(searchResults) { product in
                        ProductRow(product: product)
                            .onTapGesture {
                                onSelect(product)
                                dismiss()
                            }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Amazon Products")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        
        isLoading = true
        error = nil
        
        Task {
            do {
                searchResults = try await AmazonService.shared.searchProducts(query: searchText)
                isLoading = false
            } catch {
                self.error = error
                isLoading = false
            }
        }
    }
}

struct ProductRow: View {
    let product: AmazonProduct
    
    var body: some View {
        HStack(spacing: 12) {
            // This would be an actual image from Amazon
            Image(systemName: "gift.fill")
                .font(.title)
                .frame(width: 50, height: 50)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.system(size: 16, weight: .medium))
                    .lineLimit(2)
                
                HStack {
                    Text("$\(product.currentPrice, specifier: "%.2f")")
                        .font(.system(size: 15, weight: .semibold))
                    
                    if product.currentPrice < product.price {
                        Text("↓ \(Int(((product.price - product.currentPrice) / product.price) * 100))%")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                
                Text("Updated \(product.lastUpdated.formatted(.relative(presentation: .named)))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
} 