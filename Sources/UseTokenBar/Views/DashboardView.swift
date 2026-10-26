import SwiftUI

public struct DashboardView: View {
    @ObservedObject var aggregator: TokenAggregator
    @ObservedObject var preferences: UserPreferences = .shared

    public init(aggregator: TokenAggregator = .shared) {
        self.aggregator = aggregator
    }

    public var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .foregroundColor(.purple)
                    Text("Use Token Bar")
                        .font(.system(size: 14, weight: .bold))
                }

                Spacer()

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        preferences.showingSettings.toggle()
                    }
                }) {
                    Image(systemName: preferences.showingSettings ? "xmark.circle" : "gearshape")
                        .font(.system(size: 12))
                        .foregroundColor(preferences.showingSettings ? .primary : .secondary)
                }
                .buttonStyle(.plain)
                .help(preferences.showingSettings ? "Voltar ao painel" : "Preferências")

                Button(action: {
                    aggregator.refreshMetrics()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Atualizar métricas agora")

                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    Image(systemName: "power")
                        .font(.system(size: 11))
                        .foregroundColor(.red.opacity(0.8))
                }
                .buttonStyle(.plain)
                .help("Encerrar aplicativo")
            }
            .padding(.bottom, 2)

            if preferences.showingSettings {
                settingsView
            } else {
                mainDashboardView
            }
        }
        .padding(14)
        .frame(width: 350)
    }

    @ViewBuilder
    private var mainDashboardView: some View {
        if aggregator.stats.totalTokens > preferences.alertThresholdTokens {
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.yellow)
                Text("Limite de tokens na sessão atingido (\(TokenStats.formattedNumber(preferences.alertThresholdTokens)))")
                    .font(.system(size: 10, weight: .medium))
                Spacer()
            }
            .padding(6)
            .background(Color.yellow.opacity(0.15))
            .cornerRadius(6)
        }

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
                caption: "US$ \(String(format: "%.2f", preferences.costPerMillionTokens))/M",
                icon: "dollarsign.circle.fill",
                color: .green
            )

            MetricCard(
                title: "Velocidade",
                value: String(format: "%.0f t/s", aggregator.stats.tokensPerSecond),
                caption: aggregator.isGenerating ? "Gerando" : "Ocioso",
                icon: "bolt.fill",
                color: aggregator.isGenerating ? .orange : .gray
            )
        }

        // Breakdown
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

        // Historical Chart
        StatsChartView(history: aggregator.historyPoints)

        // Active Agents Section
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Agentes e Programas de IA")
                    .font(.system(size: 11, weight: .bold))
                Spacer()
                Text("\(aggregator.activeAgents.count) ativos")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }

            if aggregator.activeAgents.isEmpty {
                HStack {
                    Spacer()
                    Text("Nenhum agente em execução detectado.")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.vertical, 12)
            } else {
                ScrollView {
                    VStack(spacing: 6) {
                        ForEach(aggregator.activeAgents) { agent in
                            AgentRowView(agent: agent)
                        }
                    }
                }
                .frame(maxHeight: 150)
            }
        }

        Divider()

        // Footer
        HStack {
            Text("Antigravity • VS Code • Cursor • Codex")
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

    @ViewBuilder
    private var settingsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Configurações do Monitor")
                .font(.system(size: 12, weight: .bold))

            VStack(alignment: .leading, spacing: 4) {
                Text("Exibição na Barra de Menus")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)

                Picker("", selection: Binding(
                    get: { preferences.displayMode },
                    set: { preferences.displayMode = $0 }
                )) {
                    ForEach(MenuBarDisplayMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode.rawValue)
                    }
                }
                .pickerStyle(.segmented)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Custo por Milhão de Tokens:")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(String(format: "$%.2f", preferences.costPerMillionTokens))
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                }
                Slider(value: Binding(
                    get: { preferences.costPerMillionTokens },
                    set: { preferences.costPerMillionTokens = $0 }
                ), in: 0.5...15.0, step: 0.25)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Alerta de Limite na Sessão:")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(TokenStats.formattedNumber(preferences.alertThresholdTokens))
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                }
                Slider(value: Binding(
                    get: { Double(preferences.alertThresholdTokens) },
                    set: { preferences.alertThresholdTokens = Int($0) }
                ), in: 25_000...1_000_000, step: 25_000)
            }

            Divider()

            HStack {
                Button("Restaurar Padrões") {
                    preferences.displayMode = MenuBarDisplayMode.iconAndTokens.rawValue
                    preferences.costPerMillionTokens = 2.50
                    preferences.alertThresholdTokens = 150_000
                }
                .buttonStyle(.borderless)
                .font(.system(size: 10))

                Spacer()

                Button("Concluído") {
                    withAnimation {
                        preferences.showingSettings = false
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
        }
        .padding(.vertical, 4)
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
