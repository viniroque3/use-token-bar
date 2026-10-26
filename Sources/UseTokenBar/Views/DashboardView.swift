import SwiftUI

public struct DashboardView: View {
    @ObservedObject var aggregator: TokenAggregator
    @ObservedObject var preferences: UserPreferences = .shared

    public init(aggregator: TokenAggregator = .shared) {
        self.aggregator = aggregator
    }

    public var body: some View {
        VStack(spacing: 14) {
            // Header
            HStack(alignment: .center) {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 26, height: 26)
                        Image(systemName: "sparkles")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 1) {
                        Text("Use Token Bar")
                            .font(.system(size: 15, weight: .bold))
                        Text("Monitor de IA em Tempo Real")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                HStack(spacing: 10) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            preferences.showingSettings.toggle()
                        }
                    }) {
                        Image(systemName: preferences.showingSettings ? "xmark.circle.fill" : "gearshape.fill")
                            .font(.system(size: 14))
                            .foregroundColor(preferences.showingSettings ? .primary : .secondary)
                    }
                    .buttonStyle(.plain)
                    .help(preferences.showingSettings ? "Voltar ao painel" : "Preferências")

                    Button(action: {
                        aggregator.refreshMetrics()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("Atualizar métricas agora")

                    Button(action: {
                        NSApplication.shared.terminate(nil)
                    }) {
                        Image(systemName: "power")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.red.opacity(0.85))
                    }
                    .buttonStyle(.plain)
                    .help("Encerrar aplicativo")
                }
            }
            .padding(.bottom, 2)

            if preferences.showingSettings {
                settingsView
            } else {
                mainDashboardView
            }
        }
        .padding(16)
        .frame(width: 450)
    }

    @ViewBuilder
    private var mainDashboardView: some View {
        // Active AI Model Banner & Quick Switcher
        VStack(spacing: 8) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(modelColorGradient.opacity(0.18))
                        .frame(width: 36, height: 36)
                    Image(systemName: modelIconName)
                        .font(.system(size: 16))
                        .foregroundColor(modelAccentColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text("IA Em Uso:")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                        Text(preferences.selectedModel)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                    }

                    Text("Raciocínio & Geração Ativa • Contexto Estendido")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }

                Spacer()

                HStack(spacing: 4) {
                    Circle()
                        .fill(aggregator.isGenerating ? Color.green : Color.orange)
                        .frame(width: 7, height: 7)
                    Text(aggregator.isGenerating ? "Processando" : "Pronto")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(aggregator.isGenerating ? .green : .orange)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background((aggregator.isGenerating ? Color.green : Color.orange).opacity(0.12))
                .clipShape(Capsule())
            }
            .padding(10)
            .background(Color(NSColor.controlBackgroundColor).opacity(0.8))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(modelAccentColor.opacity(0.2), lineWidth: 1)
            )

            // Quick Model Selector Chips
            HStack(spacing: 6) {
                ForEach(["Gemini 3.8 Flash", "Argon Reasoning", "Claude Opus 5.5"], id: \.self) { model in
                    let isSelected = preferences.selectedModel == model
                    Button(action: {
                        preferences.selectedModel = model
                        aggregator.refreshMetrics()
                    }) {
                        HStack(spacing: 4) {
                            if isSelected {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 8, weight: .bold))
                            }
                            Text(model.replacingOccurrences(of: "Gemini ", with: "").replacingOccurrences(of: "Claude ", with: "").replacingOccurrences(of: " Reasoning", with: ""))
                                .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(isSelected ? modelAccentColor.opacity(0.22) : Color(NSColor.controlBackgroundColor).opacity(0.5))
                        .foregroundColor(isSelected ? modelAccentColor : .secondary)
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(isSelected ? modelAccentColor.opacity(0.4) : Color.clear, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
        }

        // Export Feedback message
        if let msg = preferences.exportStatusMessage {
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text(msg)
                    .font(.system(size: 10, weight: .medium))
                Spacer()
            }
            .padding(6)
            .background(Color.green.opacity(0.15))
            .cornerRadius(6)
        }

        // Warning banner if threshold exceeded
        if aggregator.stats.totalTokens > preferences.alertThresholdTokens {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.yellow)
                Text("Limite de tokens na sessão atingido (\(TokenStats.formattedNumber(preferences.alertThresholdTokens)))")
                    .font(.system(size: 11, weight: .medium))
                Spacer()
            }
            .padding(8)
            .background(Color.yellow.opacity(0.15))
            .cornerRadius(8)
        }

        // Metrics Grid
        HStack(spacing: 10) {
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
                caption: aggregator.isGenerating ? "Ativo" : "Ocioso",
                icon: "bolt.fill",
                color: aggregator.isGenerating ? .orange : .gray
            )
        }

        // Breakdown Pills
        HStack(spacing: 8) {
            TokenPill(title: "Entrada", count: aggregator.stats.inputTokens, color: .blue)
            TokenPill(title: "Saída", count: aggregator.stats.outputTokens, color: .purple)
            TokenPill(title: "Cache", count: aggregator.stats.cachedTokens, color: .green)
        }

        // Historical Chart
        StatsChartView(history: aggregator.historyPoints)

        // Active Agents Section
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Agentes e Programas Conectados")
                    .font(.system(size: 12, weight: .bold))
                Spacer()
                Text("\(aggregator.activeAgents.count) detectados")
                    .font(.system(size: 10, weight: .medium))
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
                .padding(.vertical, 14)
            } else {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(aggregator.activeAgents) { agent in
                            AgentRowView(agent: agent)
                        }
                    }
                }
                .frame(maxHeight: 160)
            }
        }

        Divider()

        // Footer with Export CSV & Reset
        HStack {
            Button(action: {
                if let url = ExportReportService.shared.exportCSV(stats: aggregator.stats, agents: aggregator.activeAgents, model: preferences.selectedModel) {
                    preferences.exportStatusMessage = "CSV exportado: \(url.lastPathComponent)"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                        preferences.exportStatusMessage = nil
                    }
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 10))
                    Text("Exportar CSV")
                        .font(.system(size: 10, weight: .medium))
                }
            }
            .buttonStyle(.borderless)

            Spacer()

            Button("Zerar Sessão") {
                aggregator.stats = TokenStats()
                aggregator.refreshMetrics()
            }
            .buttonStyle(.borderless)
            .font(.system(size: 11, weight: .medium))
        }
    }

    @ViewBuilder
    private var settingsView: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Configurações Avançadas")
                .font(.system(size: 14, weight: .bold))

            // Model Selection in Settings
            VStack(alignment: .leading, spacing: 6) {
                Text("Modelo Padrão em Uso")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)

                Picker("", selection: Binding(
                    get: { preferences.selectedModel },
                    set: {
                        preferences.selectedModel = $0
                        aggregator.refreshMetrics()
                    }
                )) {
                    ForEach(UserPreferences.availablePresetModels, id: \.self) { model in
                        Text(model).tag(model)
                    }
                }
                .pickerStyle(.menu)
            }

            // Menu Bar Display Mode
            VStack(alignment: .leading, spacing: 6) {
                Text("Formato do Ícone na Barra de Menus")
                    .font(.system(size: 11, weight: .semibold))
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

            // Toggles: Launch at Login & Notifications
            VStack(spacing: 8) {
                Toggle(isOn: Binding(
                    get: { preferences.notificationsEnabled },
                    set: { preferences.notificationsEnabled = $0 }
                )) {
                    Text("Notificações Nativas do macOS (Alerta de Limite)")
                        .font(.system(size: 11, weight: .medium))
                }
                .toggleStyle(.checkbox)

                Toggle(isOn: Binding(
                    get: { LaunchAtLoginService.shared.isEnabled },
                    set: { _ = LaunchAtLoginService.shared.setEnabled($0) }
                )) {
                    Text("Iniciar Automaticamente ao Ligar o Mac (Launch at Login)")
                        .font(.system(size: 11, weight: .medium))
                }
                .toggleStyle(.checkbox)
            }
            .padding(8)
            .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
            .cornerRadius(8)

            // Pricing Slider
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Custo Médio por 1M de Tokens:")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(String(format: "$%.2f", preferences.costPerMillionTokens))
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                }
                Slider(value: Binding(
                    get: { preferences.costPerMillionTokens },
                    set: { preferences.costPerMillionTokens = $0 }
                ), in: 0.5...15.0, step: 0.25)
            }

            // Threshold Slider
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Alerta de Limite na Sessão:")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(TokenStats.formattedNumber(preferences.alertThresholdTokens))
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                }
                Slider(value: Binding(
                    get: { Double(preferences.alertThresholdTokens) },
                    set: { preferences.alertThresholdTokens = Int($0) }
                ), in: 25_000...1_000_000, step: 25_000)
            }

            Divider()

            HStack {
                Button("Restaurar Padrões") {
                    preferences.displayMode = MenuBarDisplayMode.iconModelAndTokens.rawValue
                    preferences.selectedModel = "Gemini 3.8 Flash"
                    preferences.costPerMillionTokens = 2.50
                    preferences.alertThresholdTokens = 200_000
                    preferences.notificationsEnabled = true
                    _ = LaunchAtLoginService.shared.setEnabled(false)
                    aggregator.refreshMetrics()
                }
                .buttonStyle(.borderless)
                .font(.system(size: 11))

                Spacer()

                Button("Salvar e Fechar") {
                    withAnimation {
                        preferences.showingSettings = false
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
            }
        }
        .padding(.vertical, 6)
    }

    private var modelAccentColor: Color {
        let m = preferences.selectedModel
        if m.contains("Flash") { return .purple }
        if m.contains("Argon") { return .blue }
        if m.contains("Opus") { return .orange }
        return .green
    }

    private var modelIconName: String {
        let m = preferences.selectedModel
        if m.contains("Flash") { return "bolt.fill" }
        if m.contains("Argon") { return "brain" }
        if m.contains("Opus") { return "theatermasks.fill" }
        return "cpu"
    }

    private var modelColorGradient: LinearGradient {
        LinearGradient(
            colors: [modelAccentColor, modelAccentColor.opacity(0.6)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let caption: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(color)
                Spacer()
            }
            Text(value)
                .font(.system(size: 17, weight: .bold, design: .monospaced))
                .foregroundColor(.primary)
            Text(caption)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.85))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
    }
}

struct TokenPill: View {
    let title: String
    let count: Int
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text("\(title):")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
            Text(TokenStats.formattedNumber(count))
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.6))
        .cornerRadius(6)
    }
}
