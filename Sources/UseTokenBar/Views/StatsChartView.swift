import SwiftUI
import Charts

public struct StatsChartView: View {
    public let history: [TokenDataPoint]

    public init(history: [TokenDataPoint]) {
        self.history = history
    }

    private let appleBlue = Color(red: 0.0, green: 0.478, blue: 1.0)

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Vazão e Histórico de Tokens")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(red: 0.12, green: 0.12, blue: 0.14))
                Spacer()
                Text("Últimas horas")
                    .font(.system(size: 11))
                    .foregroundColor(Color(red: 0.55, green: 0.55, blue: 0.58))
            }

            Chart {
                ForEach(history) { point in
                    LineMark(
                        x: .value("Hora", point.timestamp),
                        y: .value("Tokens", point.tokens)
                    )
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 1.3, lineCap: .round, lineJoin: .round))
                    .foregroundStyle(appleBlue)

                    AreaMark(
                        x: .value("Hora", point.timestamp),
                        y: .value("Tokens", point.tokens)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [appleBlue.opacity(0.12), appleBlue.opacity(0.01)],
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
                        .foregroundStyle(Color(red: 0.55, green: 0.55, blue: 0.58))
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) { value in
                    if let val = value.as(Int.self) {
                        AxisValueLabel(TokenStats.formattedNumber(val))
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundStyle(Color(red: 0.55, green: 0.55, blue: 0.58))
                    }
                }
            }
            .frame(height: 115)
        }
        .padding(14)
        .background(Color(red: 0.975, green: 0.978, blue: 0.985))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
    }
}
