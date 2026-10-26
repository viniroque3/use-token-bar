import Foundation
import SQLite3

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
            let files = try fileManager.contentsOfDirectory(
                at: convDir,
                includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey],
                options: .skipsHiddenFiles
            )
            let dbFiles = files.filter { $0.pathExtension == "db" }
                .sorted {
                    let d1 = (try? $0.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast
                    let d2 = (try? $1.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast
                    return d1 > d2
                }

            if let latestDB = dbFiles.first {
                let values = try? latestDB.resourceValues(forKeys: [.contentModificationDateKey, .fileSizeKey])
                let modDate = values?.contentModificationDate ?? Date()

                let dbMetrics = queryDatabaseMetrics(dbPath: latestDB.path)

                // 1 token ~= 3.5 to 4 characters of structured payload
                let estimatedTokens = max(dbMetrics.totalPayloadBytes / 4, dbMetrics.totalSteps * 450)
                totalEstimatedTokens += estimatedTokens

                let isActivelyRunning = dbMetrics.activeStepsCount > 0
                let isRecent = Date().timeIntervalSince(modDate) < 600

                let executionState: AgentExecutionState
                let actionText: String

                if isActivelyRunning {
                    executionState = .generating
                    actionText = "Executando passo #\(dbMetrics.totalSteps) (em processamento)"
                } else if isRecent {
                    executionState = .waitingInput
                    actionText = "\(dbMetrics.totalSteps) passos concluídos - Aguardando prompt"
                } else {
                    executionState = .idle
                    actionText = "Sessão pausada (\(dbMetrics.totalSteps) passos gravados)"
                }

                activeAgents.append(AgentModel(
                    name: "Antigravity Agent",
                    provider: .antigravity,
                    state: executionState,
                    currentAction: actionText,
                    tokensSession: estimatedTokens,
                    startedAt: modDate.addingTimeInterval(-Double(dbMetrics.totalSteps * 30)),
                    lastActivityAt: modDate
                ))
            }
        } catch {
            // Ignore error gracefully
        }

        return (activeAgents, totalEstimatedTokens)
    }

    private struct DBQueryMetrics {
        var totalSteps: Int = 0
        var activeStepsCount: Int = 0
        var totalPayloadBytes: Int = 0
    }

    private func queryDatabaseMetrics(dbPath: String) -> DBQueryMetrics {
        var metrics = DBQueryMetrics()
        var db: OpaquePointer?

        // Open read-only and no mutex for maximum concurrency with Antigravity IDE
        let flags = SQLITE_OPEN_READONLY | SQLITE_OPEN_NOMUTEX
        if sqlite3_open_v2(dbPath, &db, flags, nil) == SQLITE_OK {
            // Query total steps and running steps (status = 2)
            let sql = "SELECT count(*), sum(case when status = 2 then 1 else 0 end), coalesce(sum(length(step_payload)), 0) FROM steps;"
            var stmt: OpaquePointer?
            if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
                if sqlite3_step(stmt) == SQLITE_ROW {
                    metrics.totalSteps = Int(sqlite3_column_int(stmt, 0))
                    metrics.activeStepsCount = Int(sqlite3_column_int(stmt, 1))
                    metrics.totalPayloadBytes = Int(sqlite3_column_int(stmt, 2))
                }
                sqlite3_finalize(stmt)
            }
        }
        sqlite3_close(db)
        return metrics
    }
}
