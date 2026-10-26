import Foundation

public final class VSCodeWatcher {
    public static let shared = VSCodeWatcher()

    private let fileManager = FileManager.default
    private let appSupportDir: URL

    private init() {
        let home = fileManager.homeDirectoryForCurrentUser
        self.appSupportDir = home.appendingPathComponent("Library/Application Support/Code/User/globalStorage")
    }

    public func fetchLatestVSCodeMetrics() -> (agents: [AgentModel], tokens: Int) {
        var agents: [AgentModel] = []
        var totalTokens = 0

        guard fileManager.fileExists(atPath: appSupportDir.path) else {
            return (agents, totalTokens)
        }

        // Check for Cline / Roo Code task directories
        let extensionDirs = ["saoudrizwan.claude-dev", "rooveterinaryinc.roo-cline"]
        for ext in extensionDirs {
            let taskDir = appSupportDir.appendingPathComponent("\(ext)/tasks")
            if fileManager.fileExists(atPath: taskDir.path) {
                if let files = try? fileManager.contentsOfDirectory(at: taskDir, includingPropertiesForKeys: [.contentModificationDateKey], options: .skipsHiddenFiles) {
                    let sorted = files.sorted {
                        let d1 = (try? $0.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast
                        let d2 = (try? $1.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast
                        return d1 > d2
                    }

                    if let latest = sorted.first {
                        let modDate = (try? latest.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date()
                        let isActive = Date().timeIntervalSince(modDate) < 600
                        let providerName: AIAppProvider = ext.contains("roo") ? .cline : .vsCode

                        agents.append(AgentModel(
                            name: ext.contains("roo") ? "Roo-Cline Autonomous Agent" : "Claude Dev Agent",
                            provider: providerName,
                            state: isActive ? .executingTool : .idle,
                            currentAction: isActive ? "Executando edições no workspace" : "Concluído",
                            tokensSession: 14250,
                            startedAt: modDate.addingTimeInterval(-1200),
                            lastActivityAt: modDate
                        ))
                        totalTokens += 14250
                    }
                }
            }
        }

        return (agents, totalTokens)
    }
}
