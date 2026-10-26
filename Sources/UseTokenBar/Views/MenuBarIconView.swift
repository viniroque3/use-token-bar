import SwiftUI

public struct MenuBarIconView: View {
    @ObservedObject var aggregator: TokenAggregator

    public init(aggregator: TokenAggregator = .shared) {
        self.aggregator = aggregator
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

            Text(TokenStats.formattedNumber(aggregator.stats.totalTokens))
                .font(.system(size: 11, weight: .semibold, design: .monospaced))

            if !aggregator.activeAgents.isEmpty {
                Circle()
                    .fill(aggregator.isGenerating ? Color.green : Color.orange)
                    .frame(width: 5, height: 5)
            }
        }
    }
}
