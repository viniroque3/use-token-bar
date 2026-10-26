import SwiftUI

public struct DashboardView: View {
    @ObservedObject var aggregator: TokenAggregator

    public init(aggregator: TokenAggregator = .shared) {
        self.aggregator = aggregator
    }

    public var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .foregroundColor(.accentColor)
                    Text("Use Token Bar")
                        .font(.system(size: 14, weight: .bold))
                }

                Spacer()

                Button(action: {
                    aggregator.refreshMetrics()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 11))
                }
                .buttonStyle(.plain)
                .help("Atualizar métricas")

                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    Image(systemName: "power")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Encerrar aplicativo")
            }
            .padding(.bottom, 2)

            // Metrics Grid
            HStack(spacing: 8) {
                MetricCard(
                    title: "Total Tokens",
                    value: TokenStats.formattedNumber(aggregator.stats.totalTokens),
                    caption: "Sessão Atual",
                    icon: "chart.bar.fill",
                    color: .purple
                )

                MetricCard(
                    title: "Custo Estimado",
                    value: String(format: "$%.3f", aggregator.stats.estimatedCostUSD),
                    caption: "Entrada/Saída",
                    icon: "dollarsign.circle.fill",
                    color: .green
                )

                MetricCard(
                    title: "Velocidade",
                    value: String(format: "%.0f t/s", aggregator.stats.tokensPerSecond),
                    caption: aggregator.isGenerating ? "Ativo" : "Ocioso",
                    icon: "bolt.fill",
                    color: aggregator.isGenerating ? .orange : .gray
                )
            }

            // In / Out breakdown
            HStack {
                Text("Entrada: \(TokenStats.formattedNumber(aggregator.stats.inputTokens))")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.secondary)
                Spacer()
                Text("Saída: \(TokenStats.formattedNumber(aggregator.stats.outputTokens))")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.secondary)
                Spacer()
                Text("Cache: \(TokenStats.formattedNumber(aggregator.stats.cachedTokens))")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 4)

            // Chart
            StatsChartView(history: aggregator.historyPoints)

            // Active Agents Section
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Agentes e Programas de IA")
                        .font(.system(size: 11, weight: .bold))
                    Spacer()
                    Text("\(aggregator.activeAgents.count) detectados")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }

                if aggregator.activeAgents.isEmpty {
                    Text("Nenhum agente ativo no momento.")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .padding(.vertical, 8)
                } else {
                    ScrollView {
                        VStack(spacing: 6) {
                            ForEach(aggregator.activeAgents) { agent in
                                AgentRowView(agent: agent)
                            }
                        }
                    }
                    .frame(maxHeight: 160)
                }
            }

            Divider()

            // Footer
            HStack {
                Text("Monitorando Antigravity, VS Code, Cursor & Codex")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                Spacer()
                Button("Zerar Sessão") {
                    aggregator.stats = TokenStats()
                    aggregator.refreshMetrics()
                }
                .buttonStyle(.borderless)
                .font(.system(size: 10))
            }
        }
        .padding(14)
        .frame(width: 340)
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let caption: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundColor(color)
                Spacer()
            }
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(.primary)
            Text(caption)
                .font(.system(size: 9))
                .foregroundColor(.secondary)
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.8))
        .cornerRadius(8)
    }
}
