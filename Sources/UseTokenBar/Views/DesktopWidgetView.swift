import SwiftUI
import AppKit

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

    // SMALL DESKTOP WIDGET (180x140)
    private var smallWidgetView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 5) {
                Circle()
                    .fill(aggregator.isGenerating ? Color(red: 0.20, green: 0.78, blue: 0.35) : appleBlue)
                    .frame(width: 6, height: 6)

                Text("\(aggregator.activeIDE) • \(preferences.selectedModel)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(textPrimary)
                    .lineLimit(1)

                Spacer()
            }

            Divider()

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
        .allowsHitTesting(false) // Let mouse clicks and drags pass directly to WindowDragView
    }

    // LARGE DESKTOP WIDGET (350x250)
    private var largeWidgetView: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(aggregator.isGenerating ? Color(red: 0.20, green: 0.78, blue: 0.35) : appleBlue)
                        .frame(width: 6, height: 6)

                    Text(aggregator.activeIDE)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(textPrimary)

                    Text("•")
                        .foregroundColor(textSecondary)

                    Text(preferences.selectedModel)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(textPrimary)
                }

                Spacer()

                Text(aggregator.isGenerating ? "Processing" : "Ready")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(aggregator.isGenerating ? Color(red: 0.20, green: 0.78, blue: 0.35) : textSecondary)
            }

            Divider()

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

            StatsChartView(history: aggregator.historyPoints)
                .frame(height: 85)

            Divider()

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
        .frame(width: 350, height: 250)
    }
}
