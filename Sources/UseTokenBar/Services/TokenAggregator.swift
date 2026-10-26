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
    @Published public var conversationTopic: String = "Macos AI Token Monitor"
    @Published public var detectedActiveModel: String = "Gemini 3.8 Flash"
    @Published public var dailyRecords: [DailyUsageRecord] = []

    private var timer: Timer?

    public init() {
        seedInitialHistory()
        refreshMetrics()
        startPeriodicSync()
    }

    private func seedInitialHistory() {
        self.historyPoints = AntigravityWatcher.shared.fetchDailyHistoryPoints(totalTokens: 282_200)
        self.dailyRecords = AntigravityWatcher.shared.fetchFirst30DailyUsageRecords(
            costPerMillion: UserPreferences.shared.costPerMillionTokens,
            model: UserPreferences.shared.selectedModel
        )
    }

    public func startPeriodicSync() {
        timer?.invalidate()
        let interval = 2.0 // Refresh every 2 seconds for dynamic feel
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.refreshMetrics()
        }
    }

    public func refreshMetrics() {
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

        // Determine active IDE (prioritizing active AI IDE with generation/activity)
        if mergedAgents.contains(where: { $0.provider == .antigravity }) || runningApps.contains(.antigravity) {
            self.activeIDE = AIAppProvider.antigravity.rawValue
        } else if let generating = mergedAgents.first(where: { $0.state == .generating || $0.state == .executingTool }) {
            self.activeIDE = generating.provider.rawValue
        } else if let activeWithTokens = mergedAgents.first(where: { $0.tokensSession > 0 }) {
            self.activeIDE = activeWithTokens.provider.rawValue
        } else if let running = runningApps.first {
            self.activeIDE = running.rawValue
        } else {
            self.activeIDE = AIAppProvider.antigravity.rawValue
        }

        // Dynamic Active Model Detection based on active IDE and processes
        let liveModel = detectCurrentLiveModel()
        self.detectedActiveModel = liveModel
        UserPreferences.shared.selectedModel = liveModel

        self.conversationTopic = AntigravityWatcher.shared.fetchCurrentConversationTopic()
        if self.dailyRecords.isEmpty {
            self.dailyRecords = AntigravityWatcher.shared.fetchFirst30DailyUsageRecords(
                costPerMillion: UserPreferences.shared.costPerMillionTokens,
                model: liveModel
            )
        }
        self.activeAgents = mergedAgents
        self.isGenerating = mergedAgents.contains { $0.state == .generating || $0.state == .executingTool }

        // Live Real Cumulative Tokens (monotonically persistent across session, no artificial floors)
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
                AIAppProvider.antigravity.rawValue: persistentTotal,
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

        // Live Dynamic Chart Feed spanning entire day from start of usage
        let now = Date()
        let currentTotal = self.stats.totalTokens

        if historyPoints.isEmpty {
            self.historyPoints = AntigravityWatcher.shared.fetchDailyHistoryPoints(totalTokens: currentTotal)
        } else if let last = historyPoints.last {
            if now.timeIntervalSince(last.timestamp) >= 15 {
                historyPoints.append(TokenDataPoint(timestamp: now, tokens: currentTotal, provider: .antigravity))
            } else if let lastIndex = historyPoints.indices.last {
                historyPoints[lastIndex] = TokenDataPoint(timestamp: now, tokens: currentTotal, provider: .antigravity)
            }
        } else {
            historyPoints.append(TokenDataPoint(timestamp: now, tokens: currentTotal, provider: .antigravity))
        }
    }

    public func detectCurrentLiveModel() -> String {
        if self.activeIDE == AIAppProvider.antigravity.rawValue {
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
        self.refreshMetrics()
    }

}
