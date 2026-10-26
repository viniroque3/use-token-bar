import SwiftUI
import Charts

public struct StatsChartView: View {
    public let history: [TokenDataPoint]

    public init(history: [TokenDataPoint]) {
        self.history = history
    }

    private let appleBlue = Color(red: 0.0, green: 0.478, blue: 1.0)
    private let textPrimary = Color(red: 0.11, green: 0.11, blue: 0.13)
    private let textSecondary = Color(red: 0.55, green: 0.55, blue: 0.58)

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Token Throughput")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(textPrimary)
                Spacer()
                Text("Recent activity")
                    .font(.system(size: 11))
                    .foregroundColor(textSecondary)
            }

            Chart {
                ForEach(history) { point in
                    LineMark(
                        x: .value("Time", point.timestamp),
                        y: .value("Tokens", point.tokens)
                    )
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 1.3, lineCap: .round, lineJoin: .round))
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
            }
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
            .frame(height: 120)
        }
        .padding(.vertical, 4)
    }
}
