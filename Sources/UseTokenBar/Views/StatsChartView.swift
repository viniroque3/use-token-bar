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

    private var displayPoints: [TokenDataPoint] {
        let todayPoints = history.filter { Calendar.current.isDateInToday($0.timestamp) }
            .sorted { $0.timestamp < $1.timestamp }

        let now = Date()

        if todayPoints.isEmpty {
            let start = Calendar.current.startOfDay(for: now).addingTimeInterval(8 * 3600)
            return [
                TokenDataPoint(timestamp: min(start, now.addingTimeInterval(-600)), tokens: 0, provider: .antigravity),
                TokenDataPoint(timestamp: now, tokens: aggregator.stats.totalTokens, provider: .antigravity)
            ]
        } else if todayPoints.count == 1, let first = todayPoints.first {
            let startOfDay = Calendar.current.startOfDay(for: first.timestamp).addingTimeInterval(8 * 3600)
            let baseTime = min(startOfDay, first.timestamp.addingTimeInterval(-1800))
            var points = [
                TokenDataPoint(timestamp: baseTime, tokens: 0, provider: first.provider),
                first
            ]
            if now.timeIntervalSince(first.timestamp) > 30 {
                points.append(TokenDataPoint(timestamp: now, tokens: first.tokens, provider: first.provider))
            }
            return points
        }

        var result = todayPoints
        if let last = todayPoints.last, now.timeIntervalSince(last.timestamp) > 30 {
            result.append(TokenDataPoint(timestamp: now, tokens: last.tokens, provider: last.provider))
        }
        return result
    }

    private var maxTokenValue: Int {
        let highest = displayPoints.map(\.tokens).max() ?? 1000
        return max(10_000, highest)
    }

    public var body: some View {
        let points = displayPoints

        VStack(alignment: .leading, spacing: 6) {
            // Header with interactive hover feedback showing daily timeline & IDE
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Daily Usage Timeline")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(textPrimary)
                    if let first = points.first, let last = points.last {
                        Text("\(first.timestamp.formatted(date: .omitted, time: .shortened)) - \(last.timestamp.formatted(date: .omitted, time: .shortened)) • \(aggregator.activeIDE) • \(aggregator.conversationTopic)")
                            .font(.system(size: 10))
                            .foregroundColor(textSecondary)
                    }
                }

                Spacer()

                if let hovered = aggregator.hoveredPoint {
                    HStack(spacing: 4) {
                        Text(TokenStats.formattedNumber(hovered.tokens))
                            .font(.system(size: 12, weight: .light, design: .rounded))
                            .foregroundColor(appleBlue)
                        Text("tokens at \(hovered.timestamp.formatted(date: .omitted, time: .standard))")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(textSecondary)
                    }
                    .transition(.opacity)
                } else {
                    HStack(spacing: 5) {
                        Circle()
                            .fill(aggregator.isGenerating ? Color(red: 0.20, green: 0.78, blue: 0.35) : appleBlue)
                            .frame(width: 5, height: 5)
                        Text(aggregator.isGenerating ? "Streaming live" : "Daily tracking")
                            .font(.system(size: 11))
                            .foregroundColor(textSecondary)
                    }
                    .transition(.opacity)
                }
            }

            // Interactive Chart
            Chart {
                ForEach(points) { point in
                    LineMark(
                        x: .value("Time", point.timestamp),
                        y: .value("Tokens", point.tokens)
                    )
                    .interpolationMethod(.linear)
                    .lineStyle(StrokeStyle(lineWidth: 1.6, lineCap: .round, lineJoin: .round))
                    .foregroundStyle(appleBlue)

                    AreaMark(
                        x: .value("Time", point.timestamp),
                        yStart: .value("Baseline", 0),
                        yEnd: .value("Tokens", point.tokens)
                    )
                    .interpolationMethod(.linear)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [appleBlue.opacity(0.18), appleBlue.opacity(0.01)],
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
                } else if let latest = points.last {
                    // Endpoint dot for live feel
                    PointMark(
                        x: .value("Latest Time", latest.timestamp),
                        y: .value("Latest Tokens", latest.tokens)
                    )
                    .symbolSize(28)
                    .foregroundStyle(aggregator.isGenerating ? Color(red: 0.20, green: 0.78, blue: 0.35) : appleBlue)
                }
            }
            .chartYScale(domain: 0 ... Int(Double(maxTokenValue) * 1.15))
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 4)) {
                    AxisValueLabel(format: .dateTime.hour().minute())
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
                                    // Find closest point in display points
                                    let closest = points.min(by: {
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
