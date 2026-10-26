import SwiftUI
import Charts

public struct StatsChartView: View {
    public let history: [TokenDataPoint]
    @ObservedObject var aggregator: TokenAggregator = .shared

    public init(history: [TokenDataPoint], aggregator: TokenAggregator = .shared) {
        self.history = history
        self.aggregator = aggregator
    }

    private let appleBlue = Color(red: 0.0, green: 0.478, blue: 1.0)
    private let textPrimary = Color(red: 0.11, green: 0.11, blue: 0.13)
    private let textSecondary = Color(red: 0.55, green: 0.55, blue: 0.58)

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Header with interactive hover feedback
            HStack(alignment: .firstTextBaseline) {
                Text("Token Throughput")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(textPrimary)

                Spacer()

                if let hovered = aggregator.hoveredPoint {
                    HStack(spacing: 4) {
                        Text(TokenStats.formattedNumber(hovered.tokens))
                            .font(.system(size: 12, weight: .light, design: .rounded))
                            .foregroundColor(appleBlue)
                        Text("tokens at \(hovered.timestamp.formatted(date: .omitted, time: .standard))")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(textSecondary)
                    }
                    .transition(.opacity)
                } else {
                    HStack(spacing: 5) {
                        Circle()
                            .fill(aggregator.isGenerating ? Color(red: 0.20, green: 0.78, blue: 0.35) : appleBlue)
                            .frame(width: 5, height: 5)
                        Text(aggregator.isGenerating ? "Streaming live" : "Recent activity")
                            .font(.system(size: 11))
                            .foregroundColor(textSecondary)
                    }
                    .transition(.opacity)
                }
            }

            // Interactive Chart
            Chart {
                ForEach(history) { point in
                    LineMark(
                        x: .value("Time", point.timestamp),
                        y: .value("Tokens", point.tokens)
                    )
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 1.4, lineCap: .round, lineJoin: .round))
                    .foregroundStyle(appleBlue)

                    AreaMark(
                        x: .value("Time", point.timestamp),
                        y: .value("Tokens", point.tokens)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [appleBlue.opacity(0.12), appleBlue.opacity(0.005)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }

                // If hovered, draw vertical hairline and indicator dot
                if let hovered = aggregator.hoveredPoint {
                    RuleMark(
                        x: .value("Hover Time", hovered.timestamp)
                    )
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [3, 3]))
                    .foregroundStyle(Color.black.opacity(0.25))

                    PointMark(
                        x: .value("Hover Time", hovered.timestamp),
                        y: .value("Hover Tokens", hovered.tokens)
                    )
                    .symbolSize(42)
                    .foregroundStyle(appleBlue)
                } else if let latest = history.last {
                    // Pulsing endpoint dot for live feel
                    PointMark(
                        x: .value("Latest Time", latest.timestamp),
                        y: .value("Latest Tokens", latest.tokens)
                    )
                    .symbolSize(28)
                    .foregroundStyle(aggregator.isGenerating ? Color(red: 0.20, green: 0.78, blue: 0.35) : appleBlue)
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 4)) {
                    AxisValueLabel(format: .dateTime.hour().minute().second())
                        .font(.system(size: 9, weight: .regular))
                        .foregroundStyle(textSecondary)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) { value in
                    if let val = value.as(Int.self) {
                        AxisValueLabel(TokenStats.formattedNumber(val))
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundStyle(textSecondary)
                    }
                }
            }
            .frame(height: 125)
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .onContinuousHover { phase in
                            switch phase {
                            case .active(let location):
                                if let date: Date = proxy.value(atX: location.x) {
                                    // Find closest point in history
                                    let closest = history.min(by: {
                                        abs($0.timestamp.timeIntervalSince(date)) < abs($1.timestamp.timeIntervalSince(date))
                                    })
                                    withAnimation(.easeOut(duration: 0.1)) {
                                        aggregator.hoveredPoint = closest
                                    }
                                }
                            case .ended:
                                withAnimation(.easeOut(duration: 0.15)) {
                                    aggregator.hoveredPoint = nil
                                }
                            }
                        }
                }
            }
        }
        .padding(.vertical, 4)
    }
}
