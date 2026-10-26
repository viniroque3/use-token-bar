import SwiftUI

public struct MenuBarIconView: View {
    @ObservedObject var aggregator: TokenAggregator
    @ObservedObject var preferences: UserPreferences

    public init(aggregator: TokenAggregator = .shared, preferences: UserPreferences = .shared) {
        self.aggregator = aggregator
        self.preferences = preferences
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

            if preferences.displayMode == MenuBarDisplayMode.iconAndTokens.rawValue {
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
