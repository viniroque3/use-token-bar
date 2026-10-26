import SwiftUI

public struct DashboardView: View {
    @ObservedObject var aggregator: TokenAggregator
    @ObservedObject var preferences: UserPreferences = .shared

    private let appleBlue = Color(red: 0.0, green: 0.478, blue: 1.0)
    private let textPrimary = Color(red: 0.11, green: 0.11, blue: 0.13)
    private let textSecondary = Color(red: 0.55, green: 0.55, blue: 0.58)
    private let cardBackground = Color(red: 0.975, green: 0.978, blue: 0.985)

    public init(aggregator: TokenAggregator = .shared) {
        self.aggregator = aggregator
    }

    public var body: some View {
        VStack(spacing: 14) {
            // Header
            HStack(alignment: .center) {
                HStack(spacing: 9) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(appleBlue)
                            .frame(width: 28, height: 28)
                        Image(systemName: "sparkles")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Use Token Bar")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(textPrimary)
                        Text("Monitor de IA em Tempo Real")
                            .font(.system(size: 11))
                            .foregroundColor(textSecondary)
                    }
                }

                Spacer()

                HStack(spacing: 8) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            preferences.showingSettings.toggle()
                        }
                    }) {
                        Image(systemName: preferences.showingSettings ? "xmark" : "gearshape")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(preferences.showingSettings ? appleBlue : textSecondary)
                            .frame(width: 28, height: 28)
                            .background(cardBackground)
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    .help(preferences.showingSettings ? "Voltar ao painel" : "Configurações")

                    Button(action: {
                        aggregator.refreshMetrics()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(textSecondary)
                            .frame(width: 28, height: 28)
                            .background(cardBackground)
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    .help("Atualizar métricas agora")

                    Button(action: {
                        NSApplication.shared.terminate(nil)
                    }) {
                        Image(systemName: "power")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(red: 1.0, green: 0.27, blue: 0.23))
                            .frame(width: 28, height: 28)
                            .background(cardBackground)
                            .cornerRadius(8)
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
        .padding(18)
        .frame(width: 450)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }

    @ViewBuilder
    private var mainDashboardView: some View {
        // Active AI Model Card & Selector (No pills, clean rounded rectangles)
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(appleBlue.opacity(0.10))
                        .frame(width: 40, height: 40)
                    Image(systemName: "cpu.fill")
                        .font(.system(size: 17))
                        .foregroundColor(appleBlue)
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text("IA Em Uso:")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(textSecondary)
                        Text(preferences.selectedModel)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(textPrimary)
                    }

                    Text("Raciocínio & Geração Ativa • Contexto Estendido")
                        .font(.system(size: 10))
                        .foregroundColor(textSecondary)
                }

                Spacer()

                // Minimal status dot and clean text without pill container
                HStack(spacing: 6) {
                    Circle()
                        .fill(aggregator.isGenerating ? Color(red: 0.20, green: 0.78, blue: 0.35) : Color(red: 1.0, green: 0.58, blue: 0.0))
                        .frame(width: 7, height: 7)
                    Text(aggregator.isGenerating ? "Processando" : "Pronto")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(aggregator.isGenerating ? Color(red: 0.15, green: 0.65, blue: 0.30) : Color(red: 0.85, green: 0.45, blue: 0.0))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.black.opacity(0.03))
                .cornerRadius(6)
            }
            .padding(12)
            .background(cardBackground)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.black.opacity(0.05), lineWidth: 1)
            )

            // Model Selector Buttons (Sleek Apple tab cards, no pills)
            HStack(spacing: 8) {
                ForEach(["Gemini 3.8 Flash", "Argon Reasoning", "Claude Opus 5.5"], id: \.self) { model in
                    let isSelected = preferences.selectedModel == model
                    Button(action: {
                        preferences.selectedModel = model
                        aggregator.refreshMetrics()
                    }) {
                        HStack(spacing: 5) {
                            if isSelected {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 9, weight: .bold))
                            }
                            Text(model.replacingOccurrences(of: "Gemini ", with: "").replacingOccurrences(of: "Claude ", with: "").replacingOccurrences(of: " Reasoning", with: ""))
                                .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(isSelected ? appleBlue.opacity(0.12) : cardBackground)
                        .foregroundColor(isSelected ? appleBlue : textSecondary)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isSelected ? appleBlue.opacity(0.35) : Color.black.opacity(0.04), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }

        // Export Feedback message
        if let msg = preferences.exportStatusMessage {
            HStack(spacing: 7) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color(red: 0.20, green: 0.78, blue: 0.35))
                    .font(.system(size: 11))
                Text(msg)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(textPrimary)
                Spacer()
            }
            .padding(8)
            .background(Color(red: 0.20, green: 0.78, blue: 0.35).opacity(0.10))
            .cornerRadius(8)
        }

        // Alert banner if threshold exceeded
        if aggregator.stats.totalTokens > preferences.alertThresholdTokens {
            HStack(spacing: 7) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(Color(red: 1.0, green: 0.58, blue: 0.0))
                    .font(.system(size: 11))
                Text("Limite da sessão atingido (\(TokenStats.formattedNumber(preferences.alertThresholdTokens)))")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(textPrimary)
                Spacer()
            }
            .padding(8)
            .background(Color(red: 1.0, green: 0.58, blue: 0.0).opacity(0.10))
            .cornerRadius(8)
        }

        // Metrics Grid (Clean white cards with subtle border)
        HStack(spacing: 10) {
            MetricCard(
                title: "Total Tokens",
                value: TokenStats.formattedNumber(aggregator.stats.totalTokens),
                caption: "Sessão Atual",
                icon: "chart.bar.fill",
                iconColor: appleBlue
            )

            MetricCard(
                title: "Custo Estimado",
                value: String(format: "$%.3f", aggregator.stats.estimatedCostUSD),
                caption: "US$ \(String(format: "%.2f", preferences.costPerMillionTokens))/M",
                icon: "dollarsign.circle.fill",
                iconColor: Color(red: 0.20, green: 0.78, blue: 0.35)
            )

            MetricCard(
                title: "Velocidade",
                value: String(format: "%.0f t/s", aggregator.stats.tokensPerSecond),
                caption: aggregator.isGenerating ? "Ativo" : "Ocioso",
                icon: "bolt.fill",
                iconColor: aggregator.isGenerating ? Color(red: 1.0, green: 0.58, blue: 0.0) : textSecondary
            )
        }

        // Unified Token Breakdown Bar (No isolated pills! Single clean rectangular card with dividers)
        HStack(spacing: 0) {
            BreakdownSection(title: "Entrada", count: aggregator.stats.inputTokens, dotColor: appleBlue)
            Divider().frame(height: 18)
            BreakdownSection(title: "Saída", count: aggregator.stats.outputTokens, dotColor: Color(red: 0.58, green: 0.30, blue: 0.90))
            Divider().frame(height: 18)
            BreakdownSection(title: "Cache", count: aggregator.stats.cachedTokens, dotColor: Color(red: 0.20, green: 0.78, blue: 0.35))
        }
        .padding(.vertical, 7)
        .background(cardBackground)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black.opacity(0.04), lineWidth: 1)
        )

        // Historical Chart with Apple Blue Fine Line
        StatsChartView(history: aggregator.historyPoints)

        // Active Agents Section
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Agentes e Programas Conectados")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(textPrimary)
                Spacer()
                Text("\(aggregator.activeAgents.count) detectados")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(textSecondary)
            }

            if aggregator.activeAgents.isEmpty {
                HStack {
                    Spacer()
                    Text("Nenhum agente em execução detectado.")
                        .font(.system(size: 11))
                        .foregroundColor(textSecondary)
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
                .frame(maxHeight: 155)
            }
        }

        Divider()

        // Footer with Clean Typography
        HStack {
            Button(action: {
                if let url = ExportReportService.shared.exportCSV(stats: aggregator.stats, agents: aggregator.activeAgents, model: preferences.selectedModel) {
                    preferences.exportStatusMessage = "CSV exportado: \(url.lastPathComponent)"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                        preferences.exportStatusMessage = nil
                    }
                }
            }) {
                HStack(spacing: 5) {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 11))
                    Text("Exportar CSV")
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundColor(appleBlue)
            }
            .buttonStyle(.plain)

            Spacer()

            Text("Antigravity • VS Code • Cursor • Codex")
                .font(.system(size: 10))
                .foregroundColor(textSecondary)

            Spacer()

            Button("Zerar Sessão") {
                aggregator.stats = TokenStats()
                aggregator.refreshMetrics()
            }
            .buttonStyle(.plain)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(textPrimary)
        }
    }

    @ViewBuilder
    private var settingsView: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Configurações do Monitor")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(textPrimary)

            VStack(alignment: .leading, spacing: 6) {
                Text("Modelo Padrão")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(textSecondary)

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

            VStack(alignment: .leading, spacing: 6) {
                Text("Formato na Barra de Menus")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(textSecondary)

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

            VStack(spacing: 8) {
                Toggle(isOn: Binding(
                    get: { preferences.notificationsEnabled },
                    set: { preferences.notificationsEnabled = $0 }
                )) {
                    Text("Notificações do macOS ao atingir limite")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(textPrimary)
                }
                .toggleStyle(.checkbox)

                Toggle(isOn: Binding(
                    get: { LaunchAtLoginService.shared.isEnabled },
                    set: { _ = LaunchAtLoginService.shared.setEnabled($0) }
                )) {
                    Text("Iniciar automaticamente com o macOS (Login)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(textPrimary)
                }
                .toggleStyle(.checkbox)
            }
            .padding(10)
            .background(cardBackground)
            .cornerRadius(10)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Custo por 1M de Tokens:")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(textSecondary)
                    Spacer()
                    Text(String(format: "$%.2f", preferences.costPerMillionTokens))
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(textPrimary)
                }
                Slider(value: Binding(
                    get: { preferences.costPerMillionTokens },
                    set: { preferences.costPerMillionTokens = $0 }
                ), in: 0.5...15.0, step: 0.25)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Alerta de Limite na Sessão:")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(textSecondary)
                    Spacer()
                    Text(TokenStats.formattedNumber(preferences.alertThresholdTokens))
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(textPrimary)
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
                .buttonStyle(.plain)
                .font(.system(size: 11))
                .foregroundColor(textSecondary)

                Spacer()

                Button("Concluído") {
                    withAnimation {
                        preferences.showingSettings = false
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
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
    let iconColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundColor(iconColor)
                Spacer()
            }
            Text(value)
                .font(.system(size: 17, weight: .bold, design: .monospaced))
                .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.13))
            Text(caption)
                .font(.system(size: 10))
                .foregroundColor(Color(red: 0.55, green: 0.55, blue: 0.58))
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.975, green: 0.978, blue: 0.985))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.04), lineWidth: 1)
        )
    }
}

struct BreakdownSection: View {
    let title: String
    let count: Int
    let dotColor: Color

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(dotColor)
                .frame(width: 6, height: 6)
            Text("\(title):")
                .font(.system(size: 10, weight: .regular))
                .foregroundColor(Color(red: 0.55, green: 0.55, blue: 0.58))
            Text(TokenStats.formattedNumber(count))
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.18))
        }
        .frame(maxWidth: .infinity)
    }
}
