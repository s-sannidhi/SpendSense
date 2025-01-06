import Foundation

class AmazonService {
    static let shared = AmazonService()
    
    private init() {}
    
    func searchProducts(query: String) async throws -> [AmazonProduct] {
        // URL encode the search query
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://www.amazon.com/s?k=\(encodedQuery)") else {
            throw AmazonError.invalidQuery
        }
        
        // Create request with headers to mimic a browser
        var request = URLRequest(url: url)
        request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36", forHTTPHeaderField: "User-Agent")
        request.addValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        guard let htmlString = String(data: data, encoding: .utf8) else {
            throw AmazonError.invalidResponse
        }
        
        // Parse the HTML to extract product information
        return try parseSearchResults(html: htmlString)
    }
    
    private func parseSearchResults(html: String) throws -> [AmazonProduct] {
        var products: [AmazonProduct] = []
        
        // Basic HTML parsing using string operations
        // Note: This is a simplified example and might need adjustment based on Amazon's HTML structure
        let productBlocks = html.components(separatedBy: "data-asin=")
        
        for block in productBlocks.dropFirst() {
            if let title = extractValue(from: block, startMarker: "alt=\"", endMarker: "\""),
               let priceString = extractValue(from: block, startMarker: "a-price-whole\">", endMarker: "<"),
               let price = Double(priceString),
               let asin = extractValue(from: block, startMarker: "\"", endMarker: "\"") {
                
                let productUrl = "https://www.amazon.com/dp/\(asin)"
                let imageUrl = extractValue(from: block, startMarker: "src=\"", endMarker: "\"") ?? ""
                
                let product = AmazonProduct(
                    title: title,
                    price: price,
                    imageUrl: imageUrl,
                    productUrl: productUrl,
                    currentPrice: price,
                    priceHistory: [price],
                    lastUpdated: Date()
                )
                products.append(product)
            }
        }
        
        return products
    }
    
    private func extractValue(from text: String, startMarker: String, endMarker: String) -> String? {
        guard let startRange = text.range(of: startMarker),
              let endRange = text[startRange.upperBound...].range(of: endMarker) else {
            return nil
        }
        
        return String(text[startRange.upperBound..<endRange.lowerBound])
    }
    
    enum AmazonError: Error, LocalizedError {
        case invalidQuery
        case invalidResponse
        case searchFailed
        
        var errorDescription: String? {
            switch self {
            case .invalidQuery:
                return "Invalid search query"
            case .invalidResponse:
                return "Could not process Amazon's response"
            case .searchFailed:
                return "Search failed. Please try again."
            }
        }
    }
} 