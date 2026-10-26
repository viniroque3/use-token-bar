import SwiftUI
import AppKit
import Charts

public enum DesktopWidgetSize: String, CaseIterable, Identifiable {
    case off = "Off"
    case small = "Small"
    case large = "Large"

    public var id: String { rawValue }
}

// Native Cocoa window drag helper for effortless dragging anywhere on the widget
struct WindowDragView: NSViewRepresentable {
    func makeNSView(context: Context) -> DragNSView {
        return DragNSView()
    }

    func updateNSView(_ nsView: DragNSView, context: Context) {}

    class DragNSView: NSView {
        override var mouseDownCanMoveWindow: Bool { true }

        override func mouseDown(with event: NSEvent) {
            window?.performDrag(with: event)
        }
    }
}

// Dedicated compact chart for Desktop Widget without headers or overlapping labels
struct WidgetMiniChartView: View {
    let history: [TokenDataPoint]
    let isGenerating: Bool
    private let appleBlue = Color(red: 0.0, green: 0.478, blue: 1.0)
    private let textSecondary = Color(red: 0.55, green: 0.55, blue: 0.58)

    var body: some View {
        Chart {
            ForEach(history) { point in
                LineMark(
                    x: .value("Time", point.timestamp),
                    y: .value("Tokens", point.tokens)
                )
                .interpolationMethod(.monotone)
                .lineStyle(StrokeStyle(lineWidth: 1.6, lineCap: .round, lineJoin: .round))
                .foregroundStyle(appleBlue)

                AreaMark(
                    x: .value("Time", point.timestamp),
                    y: .value("Tokens", point.tokens)
                )
                .interpolationMethod(.monotone)
                .foregroundStyle(
                    LinearGradient(
                        colors: [appleBlue.opacity(0.14), appleBlue.opacity(0.005)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }

            if let latest = history.last {
                PointMark(
                    x: .value("Time", latest.timestamp),
                    y: .value("Tokens", latest.tokens)
                )
                .symbolSize(26)
                .foregroundStyle(isGenerating ? Color(red: 0.20, green: 0.78, blue: 0.35) : appleBlue)
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 4)) {
                AxisValueLabel(format: .dateTime.hour().minute())
                    .font(.system(size: 8, weight: .regular))
                    .foregroundStyle(textSecondary)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: 2)) { value in
                if let val = value.as(Int.self) {
                    AxisValueLabel(TokenStats.formattedNumber(val))
                        .font(.system(size: 8, design: .monospaced))
                        .foregroundStyle(textSecondary)
                }
            }
        }
        .frame(height: 75)
    }
}

public struct DesktopWidgetView: View {
    @ObservedObject var aggregator: TokenAggregator = .shared
    @ObservedObject var preferences: UserPreferences = .shared
    public let size: DesktopWidgetSize

    private let appleBlue = Color(red: 0.0, green: 0.478, blue: 1.0)
    private let textPrimary = Color(red: 0.11, green: 0.11, blue: 0.13)
    private let textSecondary = Color(red: 0.55, green: 0.55, blue: 0.58)

    public var body: some View {
        ZStack {
            // Full background drag area allowing user to drag the widget from anywhere
            WindowDragView()

            Group {
                if size == .small {
                    smallWidgetView
                } else {
                    largeWidgetView
                }
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: size == .small ? 20 : 24, style: .continuous))
    }

    // SMALL DESKTOP WIDGET (200x145)
    private var smallWidgetView: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header Row 1: Active IDE & Model
            HStack(spacing: 5) {
                Circle()
                    .fill(Color(red: 0.48, green: 0.23, blue: 0.93))
                    .frame(width: 6, height: 6)

                Text(aggregator.activeIDE.contains("(") ? aggregator.activeIDE.replacingOccurrences(of: " Projects", with: "P").replacingOccurrences(of: " Project", with: "P") : (aggregator.activeIDE.components(separatedBy: " ").first ?? aggregator.activeIDE))
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(textPrimary)

                Text("•")
                    .foregroundColor(textSecondary)

                Text(preferences.selectedModel)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(textSecondary)
                    .lineLimit(1)

                Spacer()
            }

            // Header Row 2: Topic
            Text(aggregator.conversationTopic)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(appleBlue)
                .lineLimit(1)

            Divider()

            // Tokens
            VStack(alignment: .leading, spacing: 1) {
                Text("TOKENS")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(textSecondary)
                    .tracking(0.5)

                Text(TokenStats.formattedNumber(aggregator.stats.totalTokens))
                    .font(.system(size: 24, weight: .light, design: .rounded))
                    .foregroundColor(appleBlue)
            }

            Spacer(minLength: 0)

            Divider()

            // Cost & Speed
            HStack {
                Text(String(format: "$%.3f", aggregator.stats.estimatedCostUSD))
                    .font(.system(size: 11, weight: .light, design: .rounded))
                    .foregroundColor(textPrimary)

                Spacer()

                Text(String(format: "%.0f t/s", aggregator.stats.tokensPerSecond))
                    .font(.system(size: 11, weight: .light, design: .rounded))
                    .foregroundColor(aggregator.isGenerating ? Color(red: 0.20, green: 0.78, blue: 0.35) : textSecondary)
            }
        }
        .padding(14)
        .frame(width: 200, height: 145)
        .allowsHitTesting(false)
    }

    // LARGE DESKTOP WIDGET (380x285)
    private var largeWidgetView: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header Row 1: Active IDE & Model + Status
            HStack(alignment: .center) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color(red: 0.48, green: 0.23, blue: 0.93))
                        .frame(width: 6, height: 6)

                    Text(aggregator.activeIDE)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(textPrimary)

                    Text("•")
                        .foregroundColor(textSecondary)

                    Text(preferences.selectedModel)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(textSecondary)
                }

                Spacer()

                HStack(spacing: 5) {
                    Circle()
                        .fill(aggregator.isGenerating ? Color(red: 0.20, green: 0.78, blue: 0.35) : Color(red: 1.0, green: 0.58, blue: 0.0))
                        .frame(width: 6, height: 6)
                    Text(aggregator.isGenerating ? "Processing" : "Ready")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(aggregator.isGenerating ? Color(red: 0.15, green: 0.65, blue: 0.30) : textSecondary)
                }
            }

            // Header Row 2: Conversation Topic
            HStack(spacing: 5) {
                Text("TOPIC:")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(textSecondary)
                    .tracking(0.5)
                Text(aggregator.conversationTopic)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(appleBlue)
                    .lineLimit(1)
            }

            Divider()

            // Metrics Row
            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("TOTAL TOKENS")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(textSecondary)
                        .tracking(0.5)
                    Text(TokenStats.formattedNumber(aggregator.stats.totalTokens))
                        .font(.system(size: 20, weight: .light, design: .rounded))
                        .foregroundColor(appleBlue)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Divider().frame(height: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text("COST")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(textSecondary)
                        .tracking(0.5)
                    Text(String(format: "$%.3f", aggregator.stats.estimatedCostUSD))
                        .font(.system(size: 18, weight: .light, design: .rounded))
                        .foregroundColor(textPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 12)

                Divider().frame(height: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text("SPEED")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(textSecondary)
                        .tracking(0.5)
                    Text(String(format: "%.0f t/s", aggregator.stats.tokensPerSecond))
                        .font(.system(size: 18, weight: .light, design: .rounded))
                        .foregroundColor(textPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 12)
            }

            Divider()

            // Compact Chart without overlapping text
            WidgetMiniChartView(history: aggregator.historyPoints, isGenerating: aggregator.isGenerating)

            Divider()

            // Token Breakdown Row
            HStack {
                HStack(spacing: 4) {
                    Circle().fill(appleBlue).frame(width: 5, height: 5)
                    Text("In:")
                        .font(.system(size: 10))
                        .foregroundColor(textSecondary)
                    Text(TokenStats.formattedNumber(aggregator.stats.inputTokens))
                        .font(.system(size: 10, weight: .light, design: .rounded))
                        .foregroundColor(appleBlue)
                }
                Spacer()
                HStack(spacing: 4) {
                    Circle().fill(Color(red: 0.58, green: 0.30, blue: 0.90)).frame(width: 5, height: 5)
                    Text("Out:")
                        .font(.system(size: 10))
                        .foregroundColor(textSecondary)
                    Text(TokenStats.formattedNumber(aggregator.stats.outputTokens))
                        .font(.system(size: 10, weight: .light, design: .rounded))
                        .foregroundColor(appleBlue)
                }
                Spacer()
                HStack(spacing: 4) {
                    Circle().fill(Color(red: 0.20, green: 0.78, blue: 0.35)).frame(width: 5, height: 5)
                    Text("Cache:")
                        .font(.system(size: 10))
                        .foregroundColor(textSecondary)
                    Text(TokenStats.formattedNumber(aggregator.stats.cachedTokens))
                        .font(.system(size: 10, weight: .light, design: .rounded))
                        .foregroundColor(appleBlue)
                }
            }
        }
        .padding(16)
        .frame(width: 380, height: 285)
    }
}
