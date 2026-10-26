import Foundation
import SwiftUI

public enum MenuBarDisplayMode: String, CaseIterable, Identifiable {
    case iconAndTokens = "Ícone + Tokens"
    case iconOnly = "Apenas Ícone"
    case iconAndAgents = "Ícone + Agentes"

    public var id: String { rawValue }
}

public final class UserPreferences: ObservableObject {
    public static let shared = UserPreferences()

    @AppStorage("menubarDisplayMode") public var displayMode: String = MenuBarDisplayMode.iconAndTokens.rawValue
    @AppStorage("costPerMillionTokens") public var costPerMillionTokens: Double = 2.50
    @AppStorage("alertThresholdTokens") public var alertThresholdTokens: Int = 150_000
    @AppStorage("refreshInterval") public var refreshInterval: Double = 3.0

    @Published public var showingSettings: Bool = false

    private init() {}
}
