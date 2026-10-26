import Foundation

public final class ExportReportService {
    public static let shared = ExportReportService()

    private init() {}

    public func exportCSV(stats: TokenStats, agents: [AgentModel], model: String) -> URL? {
        let dateFormatter = ISO8601DateFormatter()
        let nowStr = dateFormatter.string(from: Date())

        var csv = "Data,Modelo_IA,Tokens_Entrada,Tokens_Saida,Tokens_Cache,Tokens_Total,Custo_Estimado_USD,Agentes_Ativos\n"
        csv += "\(nowStr),\"\(model)\",\(stats.inputTokens),\(stats.outputTokens),\(stats.cachedTokens),\(stats.totalTokens),\(String(format: "%.4f", stats.estimatedCostUSD)),\(agents.count)\n\n"

        csv += "Agente,Provedor,Estado,Tokens_Sessao,Acao_Atual\n"
        for agent in agents {
            csv += "\"\(agent.name)\",\"\(agent.provider.rawValue)\",\"\(agent.state.rawValue)\",\(agent.tokensSession),\"\(agent.currentAction.replacingOccurrences(of: "\"", with: "\"\""))\"\n"
        }

        let downloads = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Downloads")
        let filename = "UseTokenBar_Report_\(Int(Date().timeIntervalSince1970)).csv"
        let targetURL = downloads.appendingPathComponent(filename)

        do {
            try csv.write(to: targetURL, atomically: true, encoding: .utf8)
            return targetURL
        } catch {
            print("Failed to write CSV: \(error)")
            return nil
        }
    }
}
