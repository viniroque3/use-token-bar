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

    private var appIconImage: NSImage? {
        if let path = Bundle.main.path(forResource: "AppIcon", ofType: "png") {
            return NSImage(contentsOfFile: path)
        }
        return nil
    }

    public var body: some View {
        HStack(spacing: 5) {
            if let img = appIconImage {
                Image(nsImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 14, height: 14)
                    .cornerRadius(3)
            } else {
                Circle()
                    .fill(aggregator.isGenerating ? Color.green : (aggregator.activeAgents.isEmpty ? Color.gray.opacity(0.4) : Color.orange))
                    .frame(width: 6, height: 6)
            }

            if preferences.displayMode == MenuBarDisplayMode.iconModelAndTokens.rawValue {
                Text("\(modelShortName) • \(TokenStats.formattedNumber(aggregator.stats.totalTokens))")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
            } else if preferences.displayMode == MenuBarDisplayMode.iconAndTokens.rawValue {
                Text(TokenStats.formattedNumber(aggregator.stats.totalTokens))
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
            } else if preferences.displayMode == MenuBarDisplayMode.iconAndAgents.rawValue {
                Text("\(aggregator.activeAgents.count) agents")
                    .font(.system(size: 11, weight: .semibold))
            } else {
                Text("TokenBar")
                    .font(.system(size: 11, weight: .semibold))
            }
        }
    }
}
