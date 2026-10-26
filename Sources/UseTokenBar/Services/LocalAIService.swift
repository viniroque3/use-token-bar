import Foundation

public final class LocalAIService {
    public static let shared = LocalAIService()

    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 0.8
        config.timeoutIntervalForResource = 0.8
        self.session = URLSession(configuration: config)
    }

    public func checkOllamaStatus(completion: @escaping ([AgentModel]) -> Void) {
        guard let url = URL(string: "http://localhost:11434/api/tags") else {
            completion([])
            return
        }

        let task = session.dataTask(with: url) { data, response, error in
            guard error == nil, let data = data else {
                completion([])
                return
            }

            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let models = json["models"] as? [[String: Any]], !models.isEmpty {
                let modelNames = models.compactMap { $0["name"] as? String }.joined(separator: ", ")
                let agent = AgentModel(
                    name: "Ollama Local Service",
                    provider: .ollama,
                    state: .idle,
                    currentAction: "Available models: \(modelNames)",
                    tokensSession: 0,
                    startedAt: Date()
                )
                completion([agent])
            } else {
                completion([])
            }
        }
        task.resume()
    }
}
