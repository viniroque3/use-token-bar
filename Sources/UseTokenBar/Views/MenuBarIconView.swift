import SwiftUI

public struct MenuBarIconView: View {
    @ObservedObject var aggregator: TokenAggregator
    @ObservedObject var preferences: UserPreferences

    public init(aggregator: TokenAggregator = .shared, preferences: UserPreferences = .shared) {
        self.aggregator = aggregator
        self.preferences = preferences
    }

    private var modelShortName: String {
        let full = preferences.selectedModel
        if full.contains("Flash") { return "3.8 Flash" }
        if full.contains("Argon") { return "Argon" }
        if full.contains("Opus") { return "Opus 5.5" }
        if full.contains("Sonnet") { return "Sonnet" }
        if full.contains("GPT-4o") { return "GPT-4o" }
        return full
    }

    public var body: some View {
        HStack(spacing: 5) {
            if #available(macOS 14.0, *) {
                Image(systemName: aggregator.isGenerating ? "sparkles" : "brain.head.profile")
                    .foregroundColor(aggregator.isGenerating ? .green : .primary)
                    .symbolEffect(.pulse, isActive: aggregator.isGenerating)
            } else {
                Image(systemName: aggregator.isGenerating ? "sparkles" : "brain.head.profile")
                    .foregroundColor(aggregator.isGenerating ? .green : .primary)
            }

            if preferences.displayMode == MenuBarDisplayMode.iconModelAndTokens.rawValue {
                Text("\(modelShortName) • \(TokenStats.formattedNumber(aggregator.stats.totalTokens))")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
            } else if preferences.displayMode == MenuBarDisplayMode.iconAndTokens.rawValue {
                Text(TokenStats.formattedNumber(aggregator.stats.totalTokens))
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
            } else if preferences.displayMode == MenuBarDisplayMode.iconAndAgents.rawValue {
                Text("\(aggregator.activeAgents.count) ag")
                    .font(.system(size: 11, weight: .semibold))
            }

            if !aggregator.activeAgents.isEmpty {
                Circle()
                    .fill(aggregator.isGenerating ? Color.green : Color.orange)
                    .frame(width: 5, height: 5)
            }
        }
    }
}
