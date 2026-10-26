import Foundation
import SwiftUI

public enum MenuBarDisplayMode: String, CaseIterable, Identifiable {
    case iconModelAndTokens = "Modelo + Tokens"
    case iconAndTokens = "Ícone + Tokens"
    case iconAndAgents = "Ícone + Agentes"
    case iconOnly = "Apenas Ícone"

    public var id: String { rawValue }
}

public final class UserPreferences: ObservableObject {
    public static let shared = UserPreferences()

    @AppStorage("menubarDisplayMode") public var displayMode: String = MenuBarDisplayMode.iconModelAndTokens.rawValue
    @AppStorage("selectedModel") public var selectedModel: String = "Gemini 3.8 Flash"
    @AppStorage("costPerMillionTokens") public var costPerMillionTokens: Double = 2.50
    @AppStorage("alertThresholdTokens") public var alertThresholdTokens: Int = 200_000
    @AppStorage("refreshInterval") public var refreshInterval: Double = 3.0
    @AppStorage("notificationsEnabled") public var notificationsEnabled: Bool = true
    @AppStorage("launchAtLogin") public var launchAtLogin: Bool = false

    @Published public var showingSettings: Bool = false
    @Published public var exportStatusMessage: String? = nil

    public static let availablePresetModels: [String] = [
        "Gemini 3.8 Flash",
        "Argon Reasoning",
        "Claude Opus 5.5",
        "Claude 3.5 Sonnet",
        "GPT-4o Codex",
        "Ollama Local"
    ]

    private init() {}
}
