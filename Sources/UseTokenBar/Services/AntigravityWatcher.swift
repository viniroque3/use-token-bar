import Foundation

public final class AntigravityWatcher {
    public static let shared = AntigravityWatcher()

    private let fileManager = FileManager.default
    private let antigravityDir: URL

    private init() {
        let home = fileManager.homeDirectoryForCurrentUser
        self.antigravityDir = home.appendingPathComponent(".gemini/antigravity-ide")
    }

    public func fetchLatestSessionInfo() -> (activeAgents: [AgentModel], tokens: Int) {
        let convDir = antigravityDir.appendingPathComponent("conversations")
        guard fileManager.fileExists(atPath: convDir.path) else {
            return ([], 0)
        }

        var totalEstimatedTokens = 0
        var activeAgents: [AgentModel] = []

        do {
            let files = try fileManager.contentsOfDirectory(at: convDir, includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey], options: .skipsHiddenFiles)
            let dbFiles = files.filter { $0.pathExtension == "db" }
                .sorted {
                    let d1 = (try? $0.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast
                    let d2 = (try? $1.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast
                    return d1 > d2
                }

            if let latestDB = dbFiles.first {
                let values = try? latestDB.resourceValues(forKeys: [.contentModificationDateKey, .fileSizeKey])
                let modDate = values?.contentModificationDate ?? Date()
                let size = values?.fileSize ?? 0

                // Estimate tokens from conversation payload size (roughly 1 token per 4 bytes of structured data)
                let sessionTokens = max(1200, size / 8)
                totalEstimatedTokens += sessionTokens

                // If modified in the last 15 minutes, consider it active
                let isRecentlyActive = Date().timeIntervalSince(modDate) < 900

                activeAgents.append(AgentModel(
                    name: "Antigravity Pair-Programmer",
                    provider: .antigravity,
                    state: isRecentlyActive ? .generating : .idle,
                    currentAction: isRecentlyActive ? "Orquestrando ferramentas e código" : "Aguardando próximo comando",
                    tokensSession: sessionTokens,
                    startedAt: modDate.addingTimeInterval(-1800),
                    lastActivityAt: modDate
                ))
            }
        } catch {
            // Ignore filesystem scan errors
        }

        return (activeAgents, totalEstimatedTokens)
    }
}
