import SwiftUI

public enum DesktopWidgetSize: String, CaseIterable, Identifiable {
    case off = "Off"
    case small = "Small"
    case large = "Large"

    public var id: String { rawValue }
}

public struct DesktopWidgetView: View {
    @ObservedObject var aggregator: TokenAggregator = .shared
    @ObservedObject var preferences: UserPreferences = .shared
    public let size: DesktopWidgetSize

    private let appleBlue = Color(red: 0.0, green: 0.478, blue: 1.0)
    private let textPrimary = Color(red: 0.11, green: 0.11, blue: 0.13)
    private let textSecondary = Color(red: 0.55, green: 0.55, blue: 0.58)

    public var body: some View {
        Group {
            if size == .small {
                smallWidgetView
            } else {
                largeWidgetView
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: size == .small ? 20 : 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: size == .small ? 20 : 24, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.10), radius: 10, x: 0, y: 4)
    }

    // SMALL DESKTOP WIDGET (180x140)
    private var smallWidgetView: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack(spacing: 5) {
                Circle()
                    .fill(aggregator.isGenerating ? Color(red: 0.20, green: 0.78, blue: 0.35) : appleBlue)
                    .frame(width: 6, height: 6)

                Text(preferences.selectedModel)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(textPrimary)
                    .lineLimit(1)

                Spacer()
            }

            Divider()

            // Main Tokens Count
            VStack(alignment: .leading, spacing: 1) {
                Text("TOKENS")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(textSecondary)
                    .tracking(0.5)

                Text(TokenStats.formattedNumber(aggregator.stats.totalTokens))
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .foregroundColor(textPrimary)
            }

            Spacer(minLength: 0)

            Divider()

            // Footer info
            HStack {
                Text(String(format: "$%.3f", aggregator.stats.estimatedCostUSD))
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundColor(textPrimary)

                Spacer()

                Text(String(format: "%.0f t/s", aggregator.stats.tokensPerSecond))
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(aggregator.isGenerating ? Color(red: 0.20, green: 0.78, blue: 0.35) : textSecondary)
            }
        }
        .padding(14)
        .frame(width: 180, height: 140)
    }

    // LARGE DESKTOP WIDGET (350x230)
    private var largeWidgetView: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack(alignment: .center) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(aggregator.isGenerating ? Color(red: 0.20, green: 0.78, blue: 0.35) : appleBlue)
                        .frame(width: 6, height: 6)

                    Text(preferences.selectedModel)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(textPrimary)
                }

                Spacer()

                Text(aggregator.isGenerating ? "Processing" : "Ready")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(aggregator.isGenerating ? Color(red: 0.20, green: 0.78, blue: 0.35) : textSecondary)
            }

            Divider()

            // Metrics Columns
            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("TOTAL TOKENS")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(textSecondary)
                        .tracking(0.5)
                    Text(TokenStats.formattedNumber(aggregator.stats.totalTokens))
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(textPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Divider().frame(height: 34)

                VStack(alignment: .leading, spacing: 2) {
                    Text("COST")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(textSecondary)
                        .tracking(0.5)
                    Text(String(format: "$%.3f", aggregator.stats.estimatedCostUSD))
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(textPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 10)

                Divider().frame(height: 34)

                VStack(alignment: .leading, spacing: 2) {
                    Text("SPEED")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(textSecondary)
                        .tracking(0.5)
                    Text(String(format: "%.0f t/s", aggregator.stats.tokensPerSecond))
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(textPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 10)
            }

            Divider()

            // Fine Line Chart
            StatsChartView(history: aggregator.historyPoints)
                .frame(height: 85)

            Divider()

            // Bottom Breakdown
            HStack {
                HStack(spacing: 4) {
                    Circle().fill(appleBlue).frame(width: 5, height: 5)
                    Text("In: \(TokenStats.formattedNumber(aggregator.stats.inputTokens))")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(textSecondary)
                }
                Spacer()
                HStack(spacing: 4) {
                    Circle().fill(Color(red: 0.58, green: 0.30, blue: 0.90)).frame(width: 5, height: 5)
                    Text("Out: \(TokenStats.formattedNumber(aggregator.stats.outputTokens))")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(textSecondary)
                }
                Spacer()
                HStack(spacing: 4) {
                    Circle().fill(Color(red: 0.20, green: 0.78, blue: 0.35)).frame(width: 5, height: 5)
                    Text("Cache: \(TokenStats.formattedNumber(aggregator.stats.cachedTokens))")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(textSecondary)
                }
            }
        }
        .padding(16)
        .frame(width: 350, height: 250)
    }
}
