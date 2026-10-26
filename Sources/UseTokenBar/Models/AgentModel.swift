import Foundation

public enum AgentExecutionState: String, Codable {
    case generating = "Gerando Tokens"
    case executingTool = "Executando Ação"
    case waitingInput = "Aguardando Usuário"
    case idle = "Em Espera"

    public var statusColorName: String {
        switch self {
        case .generating: return "green"
        case .executingTool: return "orange"
        case .waitingInput: return "blue"
        case .idle: return "gray"
        }
    }
}

public struct AgentModel: Identifiable, Codable {
    public let id: UUID
    public let name: String
    public let provider: AIAppProvider
    public var modelName: String
    public var state: AgentExecutionState
    public var currentAction: String
    public var tokensSession: Int
    public var startedAt: Date
    public var lastActivityAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        provider: AIAppProvider,
        modelName: String = "Gemini 3.8 Flash",
        state: AgentExecutionState = .idle,
        currentAction: String = "Ocioso",
        tokensSession: Int = 0,
        startedAt: Date = Date(),
        lastActivityAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.provider = provider
        self.modelName = modelName
        self.state = state
        self.currentAction = currentAction
        self.tokensSession = tokensSession
        self.startedAt = startedAt
        self.lastActivityAt = lastActivityAt
    }
}
