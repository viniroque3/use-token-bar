import Foundation

public struct DailyUsageRecord: Identifiable, Codable {
    public let id: UUID
    public let timestamp: Date
    public let ide: String
    public let agentName: String
    public let modelName: String
    public let tokens: Int
    public let costUSD: Double

    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        ide: String,
        agentName: String,
        modelName: String,
        tokens: Int,
        costUSD: Double
    ) {
        self.id = id
        self.timestamp = timestamp
        self.ide = ide
        self.agentName = agentName
        self.modelName = modelName
        self.tokens = tokens
        self.costUSD = costUSD
    }
}
