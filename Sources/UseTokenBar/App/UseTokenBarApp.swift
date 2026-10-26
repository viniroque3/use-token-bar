import SwiftUI

@main
struct UseTokenBarApp: App {
    @StateObject private var aggregator = TokenAggregator.shared

    var body: some Scene {
        MenuBarExtra {
            DashboardView(aggregator: aggregator)
        } label: {
            MenuBarIconView(aggregator: aggregator)
        }
        .menuBarExtraStyle(.window)
    }
}
