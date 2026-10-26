import Foundation
import AppKit

public final class ProcessMonitor {
    public static let shared = ProcessMonitor()

    private init() {}

    public func detectRunningAIApplications() -> [AIAppProvider] {
        let runningApps = NSWorkspace.shared.runningApplications
        var detected: Set<AIAppProvider> = []

        for app in runningApps {
            guard let bundleId = app.bundleIdentifier?.lowercased() ?? app.localizedName?.lowercased() else {
                continue
            }

            if bundleId.contains("antigravity") {
                detected.insert(.antigravity)
            } else if bundleId.contains("cursor") {
                detected.insert(.cursor)
            } else if bundleId.contains("vscode") || bundleId.contains("com.microsoft.vscode") {
                detected.insert(.vsCode)
            }
        }

        // Check for CLI processes like ollama or codex via task inspection
        let processNames = listRunningProcessNames()
        if processNames.contains(where: { $0.contains("ollama") }) {
            detected.insert(.ollama)
        }
        if processNames.contains(where: { $0.contains("codex") || $0.contains("claude") }) {
            detected.insert(.codex)
        }

        return Array(detected)
    }

    private func listRunningProcessNames() -> [String] {
        let task = Process()
        task.launchPath = "/bin/ps"
        task.arguments = ["-axco", "command"]

        let pipe = Pipe()
        task.standardOutput = pipe

        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                return output.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespaces) }
            }
        } catch {
            // Fallback gracefully
        }
        return []
    }
}
