import SwiftUI
import Charts

public struct StatsChartView: View {
    public let history: [TokenDataPoint]

    public init(history: [TokenDataPoint]) {
        self.history = history
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Consumo Recente")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondary)

            Chart {
                ForEach(history) { point in
                    LineMark(
                        x: .value("Hora", point.timestamp),
                        y: .value("Tokens", point.tokens)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(Color.accentColor.gradient)

                    AreaMark(
                        x: .value("Hora", point.timestamp),
                        y: .value("Tokens", point.tokens)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.accentColor.opacity(0.3), Color.accentColor.opacity(0.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 3)) {
                    AxisValueLabel(format: .dateTime.hour().minute())
                        .font(.system(size: 9))
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) { value in
                    if let val = value.as(Int.self) {
                        AxisValueLabel(TokenStats.formattedNumber(val))
                            .font(.system(size: 9))
                    }
                }
            }
            .frame(height: 90)
        }
        .padding(10)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.6))
        .cornerRadius(8)
    }
}
