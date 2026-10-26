import SwiftUI
import Charts

public struct StatsChartView: View {
    public let history: [TokenDataPoint]

    public init(history: [TokenDataPoint]) {
        self.history = history
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Vazão e Histórico de Tokens")
                    .font(.system(size: 12, weight: .bold))
                Spacer()
                Text("Últimas horas")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }

            Chart {
                ForEach(history) { point in
                    LineMark(
                        x: .value("Hora", point.timestamp),
                        y: .value("Tokens", point.tokens)
                    )
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 2.5))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.purple, Color.blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                    AreaMark(
                        x: .value("Hora", point.timestamp),
                        y: .value("Tokens", point.tokens)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.purple.opacity(0.35), Color.blue.opacity(0.02)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 4)) {
                    AxisValueLabel(format: .dateTime.hour().minute())
                        .font(.system(size: 9, weight: .medium))
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) { value in
                    if let val = value.as(Int.self) {
                        AxisValueLabel(TokenStats.formattedNumber(val))
                            .font(.system(size: 9, design: .monospaced))
                    }
                }
            }
            .frame(height: 110)
        }
        .padding(12)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.7))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
    }
}
