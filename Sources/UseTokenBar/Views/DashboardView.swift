
// Configures the native MenuBar window to pure opaque white, eliminating the outer translucent margin
struct MenuBarWindowAccessor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            guard let window = view.window else { return }
            window.backgroundColor = .white
            window.isOpaque = true
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}
import SwiftUI

public struct DashboardView: View {
    @ObservedObject var aggregator: TokenAggregator
    @ObservedObject var preferences: UserPreferences = .shared

    private let appleBlue = Color(red: 0.0, green: 0.478, blue: 1.0)
    private let textPrimary = Color(red: 0.11, green: 0.11, blue: 0.13)
    private let textSecondary = Color(red: 0.55, green: 0.55, blue: 0.58)

    public init(aggregator: TokenAggregator = .shared) {
        self.aggregator = aggregator
    }

    private var activeModelsInUse: [String] {
        let models = aggregator.activeAgents
            .filter { $0.state == .generating || $0.state == .executingTool || $0.tokensSession > 0 }
            .map { $0.modelName }
        let unique = Array(NSOrderedSet(array: models)).compactMap { $0 as? String }
        return unique.isEmpty ? [preferences.selectedModel] : unique
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Use Token Bar")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(textPrimary)
                    Text("Real-Time AI Token Monitor")
                        .font(.system(size: 11))
                        .foregroundColor(textSecondary)
                }

                Spacer()

                HStack(spacing: 12) {
                    Button(preferences.showingSettings ? "Close" : "Settings") {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            preferences.showingSettings.toggle()
                        }
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(appleBlue)

                    Button("Refresh") {
                        aggregator.refreshMetrics()
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(textSecondary)

                    Button("Quit") {
                        NSApplication.shared.terminate(nil)
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color(red: 0.85, green: 0.25, blue: 0.20))
                }
            }

            Divider()

            if preferences.showingSettings {
                settingsView
            } else {
                mainDashboardView
            }
        }
        .padding(20)
        .frame(width: 450)
        .background(Color.white.ignoresSafeArea())
        .background(MenuBarWindowAccessor())
    }

    @ViewBuilder
    private var mainDashboardView: some View {
        // Active IDE & Model Section
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("ACTIVE IDE & MODEL")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(textSecondary)
                        .tracking(0.5)

                    HStack(spacing: 8) {
                        HStack(spacing: 5) {
                            Circle()
                                .fill(Color(red: 0.48, green: 0.23, blue: 0.93))
                                .frame(width: 6, height: 6)
                            Text(aggregator.activeIDE)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(textPrimary)
                        }

                        Text("•")
                            .font(.system(size: 12))
                            .foregroundColor(textSecondary)

                        HStack(spacing: 5) {
                            Circle()
                                .fill(appleBlue)
                                .frame(width: 6, height: 6)
                            Text(preferences.selectedModel)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(textPrimary)
                        }
                    }

                    HStack(spacing: 5) {
                        Text("TOPIC:")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(textSecondary)
                            .tracking(0.5)
                        Text(aggregator.conversationTopic)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(appleBlue)
                            .lineLimit(1)
                    }
                    .padding(.top, 1)
                }

                Spacer()

                HStack(spacing: 5) {
                    Circle()
                        .fill(aggregator.isGenerating ? Color(red: 0.20, green: 0.78, blue: 0.35) : Color(red: 1.0, green: 0.58, blue: 0.0))
                        .frame(width: 6, height: 6)
                    Text(aggregator.isGenerating ? "Processing" : "Ready")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(aggregator.isGenerating ? Color(red: 0.15, green: 0.65, blue: 0.30) : textSecondary)
                }
            }
        }

        // Export Feedback message
        if let msg = preferences.exportStatusMessage {
            Text(msg)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(appleBlue)
                .padding(.vertical, 2)
        }

        // Alert message if threshold exceeded
        if aggregator.stats.totalTokens > preferences.alertThresholdTokens {
            HStack(spacing: 6) {
                Circle()
                    .fill(Color(red: 1.0, green: 0.58, blue: 0.0))
                    .frame(width: 6, height: 6)
                Text("Session token threshold exceeded (\(TokenStats.formattedNumber(preferences.alertThresholdTokens)))")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(red: 0.85, green: 0.45, blue: 0.0))
            }
        }

        Divider()

        // Metrics Columns: Tokens styled with Apple Blue fine-line font
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text("TOTAL TOKENS")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(textSecondary)
                    .tracking(0.5)
                Text(TokenStats.formattedNumber(aggregator.stats.totalTokens))
                    .font(.system(size: 24, weight: .light, design: .rounded))
                    .foregroundColor(appleBlue)
                Text("Current session")
                    .font(.system(size: 10))
                    .foregroundColor(textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider().frame(height: 48)

            VStack(alignment: .leading, spacing: 2) {
                Text("ESTIMATED COST")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(textSecondary)
                    .tracking(0.5)
                Text(String(format: "$%.3f", aggregator.stats.estimatedCostUSD))
                    .font(.system(size: 24, weight: .light, design: .rounded))
                    .foregroundColor(textPrimary)
                Text(String(format: "$%.2f / 1M", preferences.costPerMillionTokens))
                    .font(.system(size: 10))
                    .foregroundColor(textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 14)

            Divider().frame(height: 48)

            VStack(alignment: .leading, spacing: 2) {
                Text("SPEED")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(textSecondary)
                    .tracking(0.5)
                Text(String(format: "%.0f t/s", aggregator.stats.tokensPerSecond))
                    .font(.system(size: 24, weight: .light, design: .rounded))
                    .foregroundColor(textPrimary)
                Text(aggregator.isGenerating ? "Active streaming" : "Idle")
                    .font(.system(size: 10))
                    .foregroundColor(textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 14)
        }
        .padding(.vertical, 2)

        Divider()

        // Token Breakdown Row with Apple Blue fine-line numbers
        HStack {
            HStack(spacing: 5) {
                Circle().fill(appleBlue).frame(width: 5, height: 5)
                Text("Input:")
                    .font(.system(size: 11))
                    .foregroundColor(textSecondary)
                Text(TokenStats.formattedNumber(aggregator.stats.inputTokens))
                    .font(.system(size: 12, weight: .light, design: .rounded))
                    .foregroundColor(appleBlue)
            }
            Spacer()
            HStack(spacing: 5) {
                Circle().fill(Color(red: 0.58, green: 0.30, blue: 0.90)).frame(width: 5, height: 5)
                Text("Output:")
                    .font(.system(size: 11))
                    .foregroundColor(textSecondary)
                Text(TokenStats.formattedNumber(aggregator.stats.outputTokens))
                    .font(.system(size: 12, weight: .light, design: .rounded))
                    .foregroundColor(appleBlue)
            }
            Spacer()
            HStack(spacing: 5) {
                Circle().fill(Color(red: 0.20, green: 0.78, blue: 0.35)).frame(width: 5, height: 5)
                Text("Cache:")
                    .font(.system(size: 11))
                    .foregroundColor(textSecondary)
                Text(TokenStats.formattedNumber(aggregator.stats.cachedTokens))
                    .font(.system(size: 12, weight: .light, design: .rounded))
                    .foregroundColor(appleBlue)
            }
        }
        .padding(.vertical, 2)

        Divider()

        // Chart Section
        StatsChartView(history: aggregator.historyPoints)

        Divider()

        // Connected Agents Section
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("CONNECTED AGENTS")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(textSecondary)
                    .tracking(0.5)
                Spacer()
                Text("\(aggregator.activeAgents.count) active")
                    .font(.system(size: 11))
                    .foregroundColor(textSecondary)
            }

            if aggregator.activeAgents.isEmpty {
                Text("No active agent processes detected.")
                    .font(.system(size: 11))
                    .foregroundColor(textSecondary)
                    .padding(.vertical, 8)
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(aggregator.activeAgents) { agent in
                            AgentRowView(agent: agent)
                        }
                    }
                }
                .frame(maxHeight: 140)
            }
        }

        Divider()

        // Footer
        HStack {
            Button("Export CSV") {
                if let url = ExportReportService.shared.exportCSV(stats: aggregator.stats, agents: aggregator.activeAgents, model: preferences.selectedModel) {
                    preferences.exportStatusMessage = "CSV exported: \(url.lastPathComponent)"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                        preferences.exportStatusMessage = nil
                    }
                }
            }
            .buttonStyle(.plain)
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(appleBlue)

            Spacer()

            Text("Antigravity • VS Code • Cursor • Codex")
                .font(.system(size: 10))
                .foregroundColor(textSecondary)

            Spacer()

            Button("Reset Session") {
                aggregator.stats = TokenStats()
                aggregator.refreshMetrics()
            }
            .buttonStyle(.plain)
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(textSecondary)
        }
    }

    @ViewBuilder
    private var settingsView: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Settings")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(textPrimary)

            VStack(alignment: .leading, spacing: 6) {
                Text("Desktop Widget Size")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(textSecondary)

                Picker("", selection: Binding(
                    get: { preferences.desktopWidgetSize },
                    set: {
                        if let size = DesktopWidgetSize(rawValue: $0) {
                            preferences.updateDesktopWidgetSize(size)
                        }
                    }
                )) {
                    ForEach(DesktopWidgetSize.allCases) { size in
                        Text(size.rawValue).tag(size.rawValue)
                    }
                }
                .pickerStyle(.segmented)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Default Active Model")
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
                Text("Menu Bar Display Format")
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

            VStack(alignment: .leading, spacing: 8) {
                Toggle(isOn: Binding(
                    get: { preferences.notificationsEnabled },
                    set: { preferences.notificationsEnabled = $0 }
                )) {
                    Text("macOS System Notifications on Threshold")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(textPrimary)
                }
                .toggleStyle(.checkbox)

                Toggle(isOn: Binding(
                    get: { LaunchAtLoginService.shared.isEnabled },
                    set: { _ = LaunchAtLoginService.shared.setEnabled($0) }
                )) {
                    Text("Launch automatically at login")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(textPrimary)
                }
                .toggleStyle(.checkbox)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Cost per 1M Tokens:")
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
                    Text("Session Alert Threshold:")
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

            // Daily Token Usage History Section (First 30 Records of the Day)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("DAILY TOKEN HISTORY (FIRST 30)")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(textSecondary)
                        .tracking(0.5)
                    Spacer()
                    Text("\(aggregator.dailyRecords.prefix(30).count) recorded today")
                        .font(.system(size: 10))
                        .foregroundColor(textSecondary)
                }

                if aggregator.dailyRecords.isEmpty {
                    Text("No daily usage records available yet.")
                        .font(.system(size: 11))
                        .foregroundColor(textSecondary)
                        .padding(.vertical, 4)
                } else {
                    // Header row
                    HStack(spacing: 6) {
                        Text("Time")
                            .frame(width: 44, alignment: .leading)
                        Text("IDE")
                            .frame(width: 80, alignment: .leading)
                        Text("Agent / Model")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Tokens")
                            .frame(width: 60, alignment: .trailing)
                        Text("Cost")
                            .frame(width: 48, alignment: .trailing)
                    }
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(textSecondary)

                    Divider()

                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(Array(aggregator.dailyRecords.prefix(30).enumerated()), id: \.element.id) { index, record in
                                HStack(spacing: 6) {
                                    Text(record.timestamp.formatted(date: .omitted, time: .standard))
                                        .font(.system(size: 10, weight: .regular))
                                        .foregroundColor(textSecondary)
                                        .frame(width: 44, alignment: .leading)

                                    Text(record.ide.components(separatedBy: " ").first ?? record.ide)
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(textPrimary)
                                        .frame(width: 80, alignment: .leading)
                                        .lineLimit(1)

                                    VStack(alignment: .leading, spacing: 1) {
                                        Text(record.agentName)
                                            .font(.system(size: 10, weight: .semibold))
                                            .foregroundColor(textPrimary)
                                            .lineLimit(1)
                                        Text(record.modelName)
                                            .font(.system(size: 9))
                                            .foregroundColor(textSecondary)
                                            .lineLimit(1)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                    Text(TokenStats.formattedNumber(record.tokens))
                                        .font(.system(size: 11, weight: .light, design: .rounded))
                                        .foregroundColor(appleBlue)
                                        .frame(width: 60, alignment: .trailing)

                                    Text(String(format: "$%.3f", record.costUSD))
                                        .font(.system(size: 10, weight: .regular, design: .monospaced))
                                        .foregroundColor(textPrimary)
                                        .frame(width: 48, alignment: .trailing)
                                }
                                .padding(.vertical, 4)

                                Divider()
                            }
                        }
                    }
                    .frame(maxHeight: 150)
                }
            }

            Divider()

            HStack {
                Button("Reset Defaults") {
                    preferences.displayMode = MenuBarDisplayMode.iconModelAndTokens.rawValue
                    preferences.selectedModel = "Gemini 3.8 Flash"
                    preferences.costPerMillionTokens = 2.50
                    preferences.alertThresholdTokens = 200_000
                    preferences.notificationsEnabled = true
                    preferences.updateDesktopWidgetSize(.off)
                    _ = LaunchAtLoginService.shared.setEnabled(false)
                    aggregator.refreshMetrics()
                }
                .buttonStyle(.plain)
                .font(.system(size: 11))
                .foregroundColor(textSecondary)

                Spacer()

                Button("Done") {
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
