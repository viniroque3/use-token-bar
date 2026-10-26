import SwiftUI

@main
struct UseTokenBarApp: App {
    @StateObject private var aggregator = TokenAggregator.shared
    @StateObject private var preferences = UserPreferences.shared

    var body: some Scene {
        MenuBarExtra {
            DashboardView(aggregator: aggregator)
        } label: {
            MenuBarIconView(aggregator: aggregator, preferences: preferences)
        }
        .menuBarExtraStyle(.window)
    }
}
