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

    public func latestActivityDateForConversation(convId: String) -> Date? {
        let brainDir = antigravityDir.appendingPathComponent("brain").appendingPathComponent(convId)
        let transcriptURL = brainDir.appendingPathComponent(".system_generated/logs/transcript.jsonl")

        guard let fileHandle = try? FileHandle(forReadingFrom: transcriptURL) else {
            return nil
        }
        defer { try? fileHandle.close() }

        let fileSize = fileHandle.seekToEndOfFile()
        guard fileSize > 0 else { return nil }

        let readLength = min(fileSize, 4096)
        fileHandle.seek(toFileOffset: fileSize - readLength)
        let data = fileHandle.readDataToEndOfFile()

        guard let text = String(data: data, encoding: .utf8) else { return nil }
        let lines = text.components(separatedBy: .newlines).reversed()

        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let standard = ISO8601DateFormatter()

        for line in lines {
            if let start = line.range(of: #"created_at":""#)?.upperBound,
               let end = line[start...].range(of: "\"")?.lowerBound {
                let s = String(line[start..<end])
                if let d = iso.date(from: s) ?? standard.date(from: s) {
                    return d
                }
            }
        }
        return nil
    }

    public func fetchLatestSessionInfo() -> (activeAgents: [AgentModel], tokens: Int) {
        let convDir = antigravityDir.appendingPathComponent("conversations")
        guard fileManager.fileExists(atPath: convDir.path) else {
            return ([], 0)
        }

        var totalEstimatedTokens = 0
        var activeAgents: [AgentModel] = []
        let now = Date()
        let isAppRunning = ProcessMonitor.shared.isAntigravityRunning()

        do {
            let files = try fileManager.contentsOfDirectory(
                at: convDir,
                includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey],
                options: .skipsHiddenFiles
            )
            let dbFiles = files.filter { $0.pathExtension == "db" }

            var todayConversations: [(convId: String, dbURL: URL, lastActivity: Date, metrics: DBQueryMetrics)] = []

            for dbFile in dbFiles {
                let cid = dbFile.deletingPathExtension().lastPathComponent
                guard let lastActivity = latestActivityDateForConversation(convId: cid) else {
                    continue
                }

                // Strictly filter to TODAY's date in local time
                if Calendar.current.isDateInToday(lastActivity) {
                    let m = queryDatabaseMetrics(dbPath: dbFile.path)
                    let est = max(m.totalPayloadBytes / 4, m.totalSteps * 450)
                    totalEstimatedTokens += est
                    todayConversations.append((convId: cid, dbURL: dbFile, lastActivity: lastActivity, metrics: m))
                }
            }

            // Sort by most recently active first
            todayConversations.sort { $0.lastActivity > $1.lastActivity }

            // Active agents are conversations active within last 20 minutes (or the most recent if app is running)
            var activeCandidates = todayConversations.filter { now.timeIntervalSince($0.lastActivity) < 1200 }
            if activeCandidates.isEmpty && isAppRunning, let top = todayConversations.first {
                activeCandidates.append(top)
            }

            let isMultiProject = activeCandidates.count > 1

            for candidate in activeCandidates {
                let dbMetrics = candidate.metrics
                let estimatedTokens = max(dbMetrics.totalPayloadBytes / 4, dbMetrics.totalSteps * 450)
                let timeSinceActivity = now.timeIntervalSince(candidate.lastActivity)

                let isActivelyRunning = isAppRunning && (dbMetrics.latestStepStatus == 2) && (timeSinceActivity < 90)
                let isRecent = timeSinceActivity < 240

                let executionState: AgentExecutionState
                let actionText: String
                let projectTitle = fetchProjectNameForConversation(convId: candidate.convId)

                if isActivelyRunning {
                    executionState = .generating
                    actionText = "Executing step #\(dbMetrics.totalSteps) - \(projectTitle)"
                } else if isRecent {
                    executionState = .waitingInput
                    actionText = "\(dbMetrics.totalSteps) steps recorded - \(projectTitle)"
                } else {
                    executionState = .idle
                    actionText = "Idle (\(projectTitle))"
                }

                let modelForProject = detectModelForConversation(convId: candidate.convId)
                let agentDisplayName = isMultiProject ? "Antigravity (\(projectTitle))" : "Antigravity Agent"

                activeAgents.append(AgentModel(
                    name: agentDisplayName,
                    provider: .antigravity,
                    modelName: modelForProject,
                    state: executionState,
                    currentAction: actionText,
                    tokensSession: estimatedTokens,
                    startedAt: candidate.lastActivity.addingTimeInterval(-Double(dbMetrics.totalSteps * 25)),
                    lastActivityAt: candidate.lastActivity
                ))
            }
        } catch {
            // Fallback gracefully
        }

        return (activeAgents, totalEstimatedTokens)
    }

    public func fetchProjectNameForConversation(convId: String) -> String {
        let brainDir = antigravityDir.appendingPathComponent("brain").appendingPathComponent(convId)
        let transcriptURL = brainDir.appendingPathComponent(".system_generated/logs/transcript.jsonl")

        if let data = try? Data(contentsOf: transcriptURL),
           let content = String(data: data.prefix(32768), encoding: .utf8) {

            // Match directory path in workspace or tool calls
            let patterns = [
                #"/Users/[^/]+/(?:Downloads|Projects|Developer)/([^/"'\\ \n\r,]+)"#,
                #"DirectoryPath":"[^"]*/(?:Downloads|Projects|Developer)/([^/"'\\ \n\r,]+)"#,
                #"TargetFile":"[^"]*/(?:Downloads|Projects|Developer)/([^/"'\\ \n\r,]+)"#
            ]

            for pat in patterns {
                if let regex = try? NSRegularExpression(pattern: pat, options: []) {
                    let range = NSRange(content.startIndex..<content.endIndex, in: content)
                    if let match = regex.firstMatch(in: content, options: [], range: range),
                       let matchRange = Range(match.range(at: 1), in: content) {
                        let candidate = String(content[matchRange])
                            .trimmingCharacters(in: CharacterSet(charactersIn: "\"\\/, '"))
                        if !candidate.isEmpty && candidate != "viniroque" && !candidate.hasPrefix(".") {
                            return candidate
                        }
                    }
                }
            }
        }

        // Check workspaceStorage for currently active workspaces
        let wsURL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support/Antigravity IDE/User/workspaceStorage")
        if let folders = try? fileManager.contentsOfDirectory(at: wsURL, includingPropertiesForKeys: [.contentModificationDateKey], options: .skipsHiddenFiles) {
            let sorted = folders.sorted {
                let d1 = (try? $0.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast
                let d2 = (try? $1.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast
                return d1 > d2
            }
            for folder in sorted {
                let jsonFile = folder.appendingPathComponent("workspace.json")
                if let data = try? Data(contentsOf: jsonFile),
                   let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let fUri = dict["folder"] as? String,
                   let decoded = fUri.removingPercentEncoding {
                    let name = (decoded as NSString).lastPathComponent
                    if !name.isEmpty && !name.hasPrefix(".") {
                        return name
                    }
                }
            }
        }

        return "Antigravity Project"
    }

    public func detectModelForConversation(convId: String) -> String {
        let brainDir = antigravityDir.appendingPathComponent("brain")
        let transcriptURL = brainDir.appendingPathComponent(convId).appendingPathComponent(".system_generated/logs/transcript.jsonl")
        if let data = try? Data(contentsOf: transcriptURL, options: .mappedIfSafe),
           let snippet = String(data: data.prefix(16384), encoding: .utf8) {
            if snippet.contains("gemini-3.8-flash") || snippet.contains("3.8 Flash") {
                return "Gemini 3.8 Flash"
            } else if snippet.contains("gemini-2.5-pro") || snippet.contains("2.5 Pro") {
                return "Gemini 2.5 Pro"
            } else if snippet.contains("claude-3-5-sonnet") || snippet.contains("Sonnet") {
                return "Claude 3.5 Sonnet"
            } else if snippet.contains("gpt-4o") {
                return "GPT-4o"
            }
        }
        return UserPreferences.shared.selectedModel
    }

    public func fetchFirst30DailyUsageRecords(costPerMillion: Double, model: String) -> [DailyUsageRecord] {
        let convDir = antigravityDir.appendingPathComponent("conversations")
        let brainDir = antigravityDir.appendingPathComponent("brain")

        var records: [DailyUsageRecord] = []

        // Load stored persistent records first
        let stored = HistoryStorageService.shared.loadStore().dailyRecords
        records.append(contentsOf: stored.filter { Calendar.current.isDateInToday($0.timestamp) })

        if let files = try? fileManager.contentsOfDirectory(
            at: convDir,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: .skipsHiddenFiles
        ) {
            for dbFile in files where dbFile.pathExtension == "db" {
                let id = dbFile.deletingPathExtension().lastPathComponent
                guard let lastActivity = latestActivityDateForConversation(convId: id),
                      Calendar.current.isDateInToday(lastActivity) else {
                    continue
                }

                let projectTitle = fetchProjectNameForConversation(convId: id)
                let transcriptURL = brainDir.appendingPathComponent(id).appendingPathComponent(".system_generated/logs/transcript.jsonl")
                let modelForRecord = detectModelForConversation(convId: id)

                if let data = try? Data(contentsOf: transcriptURL),
                   let content = String(data: data, encoding: .utf8) {
                    let lines = content.components(separatedBy: .newlines)
                    let iso = ISO8601DateFormatter()
                    iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                    let standard = ISO8601DateFormatter()

                    for line in lines {
                        guard !line.isEmpty else { continue }
                        guard line.contains("USER_EXPLICIT") || line.contains("MODEL") else { continue }

                        var stepDate: Date?
                        if let start = line.range(of: #"created_at":""#)?.upperBound,
                           let end = line[start...].range(of: "\"")?.lowerBound {
                            let str = String(line[start..<end])
                            stepDate = iso.date(from: str) ?? standard.date(from: str)
                        }

                        guard let t = stepDate, Calendar.current.isDateInToday(t) else { continue }

                        let tok = max(1450, Int(Double(line.count) * 0.45))
                        let cost = (Double(tok) / 1_000_000.0) * costPerMillion

                        let record = DailyUsageRecord(
                            timestamp: t,
                            ide: "Antigravity (\(projectTitle))",
                            agentName: "Agent (\(projectTitle))",
                            modelName: modelForRecord,
                            tokens: tok,
                            costUSD: cost
                        )

                        if !records.contains(where: { abs($0.timestamp.timeIntervalSince(t)) < 2 }) {
                            records.append(record)
                        }

                        if records.count >= 50 { break }
                    }
                }
                if records.count >= 50 { break }
            }
        }

        // Sort descending (most recent first)
        records.sort { $0.timestamp > $1.timestamp }
        return Array(records.prefix(30))
    }

    public func fetchCurrentConversationTopic() -> String {
        let wsURL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support/Antigravity IDE/User/workspaceStorage")
        if let folders = try? fileManager.contentsOfDirectory(at: wsURL, includingPropertiesForKeys: [.contentModificationDateKey], options: .skipsHiddenFiles) {
            let sortedFolders = folders.sorted {
                let d1 = (try? $0.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast
                let d2 = (try? $1.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast
                return d1 > d2
            }

            for folder in sortedFolders {
                let jsonFile = folder.appendingPathComponent("workspace.json")
                if let data = try? Data(contentsOf: jsonFile),
                   let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let fUri = dict["folder"] as? String,
                   let decoded = fUri.removingPercentEncoding {
                    let name = (decoded as NSString).lastPathComponent
                    if !name.isEmpty && !name.hasPrefix(".") {
                        return name
                    }
                }
            }
        }

        return "Use Token Bar"
    }

    public func fetchDailyHistoryPoints(totalTokens: Int) -> [TokenDataPoint] {
        let brainDir = antigravityDir.appendingPathComponent("brain")
        var todayTimestamps: [Date] = []

        let convDir = antigravityDir.appendingPathComponent("conversations")
        if let files = try? fileManager.contentsOfDirectory(at: convDir, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) {
            for dbFile in files where dbFile.pathExtension == "db" {
                let cid = dbFile.deletingPathExtension().lastPathComponent
                guard let lastActivity = latestActivityDateForConversation(convId: cid),
                      Calendar.current.isDateInToday(lastActivity) else {
                    continue
                }

                let transcriptURL = brainDir.appendingPathComponent(cid).appendingPathComponent(".system_generated/logs/transcript.jsonl")
                if let data = try? Data(contentsOf: transcriptURL),
                   let content = String(data: data, encoding: .utf8) {
                    let lines = content.components(separatedBy: .newlines)
                    let iso = ISO8601DateFormatter()
                    iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                    let standard = ISO8601DateFormatter()

                    for line in lines {
                        guard !line.isEmpty else { continue }
                        if let start = line.range(of: #"created_at":""#)?.upperBound,
                           let end = line[start...].range(of: "\"")?.lowerBound {
                            let str = String(line[start..<end])
                            if let d = iso.date(from: str) ?? standard.date(from: str),
                               Calendar.current.isDateInToday(d) {
                                todayTimestamps.append(d)
                            }
                        }
                    }
                }
            }
        }

        todayTimestamps.sort()

        let total = max(1_000, totalTokens)
        let now = Date()

        guard !todayTimestamps.isEmpty, let firstTime = todayTimestamps.first else {
            // Fresh day with no prior activity: baseline start of day up to now
            let todayStart = Calendar.current.startOfDay(for: now).addingTimeInterval(8 * 3600)
            return [
                TokenDataPoint(timestamp: todayStart, tokens: 0, provider: .antigravity),
                TokenDataPoint(timestamp: now, tokens: total, provider: .antigravity)
            ]
        }

        let sampleCount = min(25, max(8, todayTimestamps.count))
        var points: [TokenDataPoint] = []

        // Start point with 0 tokens slightly before first activity
        points.append(TokenDataPoint(
            timestamp: firstTime.addingTimeInterval(-60),
            tokens: 0,
            provider: .antigravity
        ))

        for i in 0..<sampleCount {
            let index = Int(Double(i) * Double(todayTimestamps.count - 1) / Double(sampleCount - 1))
            let time = todayTimestamps[index]
            let progress = Double(i + 1) / Double(sampleCount)
            let tokensAtPoint = Int(Double(total) * progress)
            points.append(TokenDataPoint(
                timestamp: time,
                tokens: max(500, tokensAtPoint),
                provider: .antigravity
            ))
        }

        // Always guarantee current time point with total tokens
        if now.timeIntervalSince(points.last?.timestamp ?? now) > 10 {
            points.append(TokenDataPoint(timestamp: now, tokens: total, provider: .antigravity))
        }

        // Deduplicate and ensure monotonic tokens and strictly ascending timestamps
        var cleaned: [TokenDataPoint] = []
        var runningMax = 0

        for pt in points.sorted(by: { $0.timestamp < $1.timestamp }) {
            guard Calendar.current.isDateInToday(pt.timestamp) else { continue }
            if let last = cleaned.last, abs(last.timestamp.timeIntervalSince(pt.timestamp)) < 5 {
                continue
            }
            runningMax = max(runningMax, pt.tokens)
            cleaned.append(TokenDataPoint(timestamp: pt.timestamp, tokens: runningMax, provider: pt.provider))
        }

        return cleaned
    }

    public struct DBQueryMetrics {
        public var totalSteps: Int = 0
        public var totalPayloadBytes: Int = 0
        public var latestStepStatus: Int = 0
    }

    public func queryDatabaseMetrics(dbPath: String) -> DBQueryMetrics {
        var metrics = DBQueryMetrics()
        var db: OpaquePointer?

        let flags = SQLITE_OPEN_READONLY | SQLITE_OPEN_NOMUTEX
        if sqlite3_open_v2(dbPath, &db, flags, nil) == SQLITE_OK {
            sqlite3_busy_timeout(db, 1500)
            let sql = "SELECT count(*), coalesce(sum(length(step_payload)), 0) FROM steps;"
            var stmt: OpaquePointer?
            if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
                if sqlite3_step(stmt) == SQLITE_ROW {
                    metrics.totalSteps = Int(sqlite3_column_int(stmt, 0))
                    metrics.totalPayloadBytes = Int(sqlite3_column_int(stmt, 1))
                }
                sqlite3_finalize(stmt)
            }

            let sqlLast = "SELECT status FROM steps ORDER BY idx DESC LIMIT 1;"
            if sqlite3_prepare_v2(db, sqlLast, -1, &stmt, nil) == SQLITE_OK {
                if sqlite3_step(stmt) == SQLITE_ROW {
                    metrics.latestStepStatus = Int(sqlite3_column_int(stmt, 0))
                }
                sqlite3_finalize(stmt)
            }
        }
        sqlite3_close(db)
        return metrics
    }

    public func detectActiveModel() -> String {
        let convDir = antigravityDir.appendingPathComponent("conversations")
        if let files = try? fileManager.contentsOfDirectory(at: convDir, includingPropertiesForKeys: [.contentModificationDateKey], options: .skipsHiddenFiles) {
            let dbs = files.filter { $0.pathExtension == "db" }.sorted {
                let d1 = (try? $0.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast
                let d2 = (try? $1.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast
                return d1 > d2
            }
            for db in dbs {
                let id = db.deletingPathExtension().lastPathComponent
                if let lastActivity = latestActivityDateForConversation(convId: id),
                   Calendar.current.isDateInToday(lastActivity) {
                    return detectModelForConversation(convId: id)
                }
            }
        }
        return "Gemini 3.8 Flash"
    }
}
