import Foundation

public struct TokenDataPoint: Identifiable, Codable {
    public let id: UUID
    public let timestamp: Date
    public let tokens: Int
    public let provider: AIAppProvider

    public init(id: UUID = UUID(), timestamp: Date, tokens: Int, provider: AIAppProvider) {
        self.id = id
        self.timestamp = timestamp
        self.tokens = tokens
        self.provider = provider
    }
}

public struct TokenStats: Codable {
    public var inputTokens: Int
    public var outputTokens: Int
    public var cachedTokens: Int
    public var estimatedCostUSD: Double
    public var tokensPerSecond: Double
    public var providerBreakdown: [String: Int]

    public var totalTokens: Int {
        inputTokens + outputTokens
    }

    public init(
        inputTokens: Int = 0,
        outputTokens: Int = 0,
        cachedTokens: Int = 0,
        estimatedCostUSD: Double = 0.0,
        tokensPerSecond: Double = 0.0,
        providerBreakdown: [String: Int] = [:]
    ) {
        self.inputTokens = inputTokens
        self.outputTokens = outputTokens
        self.cachedTokens = cachedTokens
        self.estimatedCostUSD = estimatedCostUSD
        self.tokensPerSecond = tokensPerSecond
        self.providerBreakdown = providerBreakdown
    }

    public static func formattedNumber(_ value: Int) -> String {
        if value >= 1_000_000 {
            return String(format: "%.1fM", Double(value) / 1_000_000.0)
        } else if value >= 1_000 {
            return String(format: "%.1fk", Double(value) / 1_000.0)
        } else {
            return "\(value)"
        }
    }
}
