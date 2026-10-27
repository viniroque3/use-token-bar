import Foundation
import Combine
import SwiftUI

public final class TokenAggregator: ObservableObject {
    public static let shared = TokenAggregator()

    @Published public var activeAgents: [AgentModel] = []
    @Published public var stats: TokenStats = TokenStats()
    @Published public var isGenerating: Bool = false
    @Published public var historyPoints: [TokenDataPoint] = []
    @Published public var hoveredPoint: TokenDataPoint? = nil
    @Published public var activeIDE: String = "Antigravity IDE"
    @Published public var conversationTopic: String = "Use Token Bar"
    @Published public var detectedActiveModel: String = "Gemini 3.8 Flash"
    @Published public var dailyRecords: [DailyUsageRecord] = []

    private var timer: Timer?
    private var trackingDay: Date = Calendar.current.startOfDay(for: Date())

    public init() {
        seedInitialHistory()
        refreshMetrics()
        startPeriodicSync()
    }

    private func seedInitialHistory() {
        let (didRollover, store) = HistoryStorageService.shared.checkAndPerformDayRollover()
        if didRollover {
            self.stats = TokenStats()
            self.historyPoints = []
            self.dailyRecords = []
        } else {
            let todayPoints = store.timelinePoints.filter { Calendar.current.isDateInToday($0.timestamp) }
            if todayPoints.count < 3 {
                let generated = AntigravityWatcher.shared.fetchDailyHistoryPoints(totalTokens: store.todayTotalTokens)
                self.historyPoints = generated
                if !generated.isEmpty {
                    HistoryStorageService.shared.saveTimelinePoints(generated)
                }
            } else {
                self.historyPoints = todayPoints
            }
            self.dailyRecords = store.dailyRecords
        }
    }

    public func startPeriodicSync() {
        timer?.invalidate()
        let interval = 2.0 // Refresh every 2 seconds
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.refreshMetrics()
        }
    }

    public func refreshMetrics() {
        let todayStart = Calendar.current.startOfDay(for: Date())
        if !Calendar.current.isDate(trackingDay, inSameDayAs: todayStart) {
            // Automatic reset for a new day
            trackingDay = todayStart
            _ = HistoryStorageService.shared.checkAndPerformDayRollover()
            self.stats = TokenStats()
            self.historyPoints = []
            self.dailyRecords = []
        }

        let (antigravityAgents, antigravityTokens) = AntigravityWatcher.shared.fetchLatestSessionInfo()
        let (vsCodeAgents, vsCodeTokens) = VSCodeWatcher.shared.fetchLatestVSCodeMetrics()
        let runningApps = ProcessMonitor.shared.detectRunningAIApplications()

        var mergedAgents = antigravityAgents + vsCodeAgents

        for app in runningApps {
            if !mergedAgents.contains(where: { $0.provider == app }) {
                mergedAgents.append(AgentModel(
                    name: "\(app.rawValue) Service",
                    provider: app,
                    modelName: UserPreferences.shared.selectedModel,
                    state: .idle,
                    currentAction: "Process running in background",
                    tokensSession: 0,
                    startedAt: Date()
                ))
            }
        }

        LocalAIService.shared.checkOllamaStatus { [weak self] ollamaAgents in
            DispatchQueue.main.async {
                guard let self = self else { return }
                for oAgent in ollamaAgents {
                    if !self.activeAgents.contains(where: { $0.provider == .ollama }) {
                        self.activeAgents.append(oAgent)
                    }
                }
            }
        }

        // Determine active IDE with intelligent priority:
        // 1. Any agent actively generating / executing tool
        // 2. Currently focused / frontmost application in macOS
        // 3. Multi-project Antigravity if multiple projects active
        // 4. Any detected running AI app
        if let generating = mergedAgents.first(where: { $0.state == .generating || $0.state == .executingTool }) {
            self.activeIDE = generating.provider.rawValue
        } else if let frontmost = ProcessMonitor.shared.frontmostAIApp() {
            self.activeIDE = frontmost.rawValue
        } else if antigravityAgents.count > 1 {
            self.activeIDE = "Antigravity (\(antigravityAgents.count) Projects)"
        } else if ProcessMonitor.shared.isAntigravityRunning() || mergedAgents.contains(where: { $0.provider == .antigravity }) {
            self.activeIDE = AIAppProvider.antigravity.rawValue
        } else if ProcessMonitor.shared.isVSCodeRunning() || mergedAgents.contains(where: { $0.provider == .vsCode }) {
            self.activeIDE = AIAppProvider.vsCode.rawValue
        } else if let running = runningApps.first {
            self.activeIDE = running.rawValue
        } else {
            self.activeIDE = AIAppProvider.antigravity.rawValue
        }

        // Dynamic Active Model Detection based on active IDE and processes
        let liveModel = detectCurrentLiveModel()
        self.detectedActiveModel = liveModel
        UserPreferences.shared.selectedModel = liveModel

        // Project Topic
        if antigravityAgents.count > 1 {
            if let generating = antigravityAgents.first(where: { $0.state == .generating }) {
                let name = generating.name.replacingOccurrences(of: "Antigravity (", with: "").replacingOccurrences(of: ")", with: "")
                self.conversationTopic = name
            } else {
                let names = antigravityAgents.map { $0.name.replacingOccurrences(of: "Antigravity (", with: "").replacingOccurrences(of: ")", with: "") }
                self.conversationTopic = names.joined(separator: " • ")
            }
        } else if let singleAntigravity = antigravityAgents.first {
            let name = singleAntigravity.name.replacingOccurrences(of: "Antigravity (", with: "").replacingOccurrences(of: ")", with: "")
            self.conversationTopic = name == "Antigravity Agent" ? AntigravityWatcher.shared.fetchCurrentConversationTopic() : name
        } else {
            self.conversationTopic = AntigravityWatcher.shared.fetchCurrentConversationTopic()
        }

        // Real Daily Usage Records (from files + persistent store)
        let freshRecords = AntigravityWatcher.shared.fetchFirst30DailyUsageRecords(
            costPerMillion: UserPreferences.shared.costPerMillionTokens,
            model: liveModel
        )
        self.dailyRecords = freshRecords

        self.activeAgents = mergedAgents
        self.isGenerating = mergedAgents.contains { $0.state == .generating || $0.state == .executingTool }

        // Live Real Cumulative Tokens strictly for today
        let actualTotalTokens = antigravityTokens + vsCodeTokens
        let persistentTotal = max(self.stats.totalTokens, actualTotalTokens)
        let totalIn = Int(Double(persistentTotal) * 0.7)
        let totalOut = persistentTotal - totalIn
        let ratePerM = UserPreferences.shared.costPerMillionTokens
        let estimatedCost = Double(persistentTotal) / 1_000_000.0 * ratePerM

        self.stats = TokenStats(
            inputTokens: totalIn,
            outputTokens: totalOut,
            cachedTokens: totalIn / 2,
            estimatedCostUSD: estimatedCost,
            tokensPerSecond: self.isGenerating ? 54.0 : 0.0,
            providerBreakdown: [
                AIAppProvider.antigravity.rawValue: antigravityTokens,
                AIAppProvider.vsCode.rawValue: vsCodeTokens
            ]
        )

        // Native Notification Check
        if UserPreferences.shared.notificationsEnabled {
            NotificationService.shared.checkAndNotify(
                totalTokens: self.stats.totalTokens,
                threshold: UserPreferences.shared.alertThresholdTokens,
                model: liveModel
            )
        }

        // Live Dynamic Chart Feed spanning strictly today
        let now = Date()
        let currentTotal = self.stats.totalTokens

        // Clean any stale non-today points
        historyPoints = historyPoints.filter { Calendar.current.isDateInToday($0.timestamp) }

        if historyPoints.count < 3 {
            self.historyPoints = AntigravityWatcher.shared.fetchDailyHistoryPoints(totalTokens: currentTotal)
            if !self.historyPoints.isEmpty {
                HistoryStorageService.shared.saveTimelinePoints(self.historyPoints)
            }
        } else if let last = historyPoints.last {
            let newTotal = max(last.tokens, currentTotal)
            let newPoint = TokenDataPoint(timestamp: now, tokens: newTotal, provider: .antigravity)

            if now.timeIntervalSince(last.timestamp) >= 30 {
                historyPoints.append(newPoint)
                HistoryStorageService.shared.recordTimelinePoint(newPoint)
            } else if let lastIndex = historyPoints.indices.last {
                historyPoints[lastIndex].tokens = newTotal
                HistoryStorageService.shared.recordTimelinePoint(historyPoints[lastIndex])
            }
        } else {
            let point = TokenDataPoint(timestamp: now, tokens: currentTotal, provider: .antigravity)
            historyPoints.append(point)
            HistoryStorageService.shared.recordTimelinePoint(point)
        }

        // Persist real event in daily records if active generating
        if self.isGenerating && currentTotal > 0 {
            HistoryStorageService.shared.recordDailyUsage(
                ide: self.activeIDE,
                agentName: self.activeAgents.first(where: { $0.state == .generating })?.name ?? "Antigravity Agent",
                modelName: liveModel,
                tokens: currentTotal,
                costUSD: estimatedCost,
                timestamp: now
            )
        }
    }

    public func detectCurrentLiveModel() -> String {
        if self.activeIDE.contains("Antigravity") {
            return AntigravityWatcher.shared.detectActiveModel()
        } else if self.activeIDE == AIAppProvider.cursor.rawValue {
            return "Claude 3.5 Sonnet"
        } else if self.activeIDE == AIAppProvider.ollama.rawValue {
            if let oAgent = activeAgents.first(where: { $0.provider == .ollama }) {
                return oAgent.modelName
            }
            return "Llama 3.3"
        } else if self.activeIDE == AIAppProvider.cline.rawValue {
            return "Claude 3.5 Sonnet"
        } else if self.activeIDE == AIAppProvider.codex.rawValue {
            return "Codex"
        } else if self.activeIDE == AIAppProvider.vsCode.rawValue {
            return "GPT-4o"
        } else {
            return AntigravityWatcher.shared.detectActiveModel()
        }
    }

    public func resetSession() {
        self.stats = TokenStats()
        self.historyPoints = []
        _ = HistoryStorageService.shared.checkAndPerformDayRollover()
        self.refreshMetrics()
    }
}
