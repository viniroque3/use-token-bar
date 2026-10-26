import Foundation

public enum AIAppProvider: String, CaseIterable, Identifiable, Codable {
    case antigravity = "Antigravity IDE"
    case vsCode = "VS Code / Copilot"
    case cline = "Cline / Roo Code"
    case codex = "Codex CLI"
    case cursor = "Cursor"
    case ollama = "Ollama / Local"

    public var id: String { rawValue }

    public var iconName: String {
        switch self {
        case .antigravity: return "sparkles"
        case .vsCode: return "curlybraces"
        case .cline: return "terminal"
        case .codex: return "cpu"
        case .cursor: return "cursorarrow.rays"
        case .ollama: return "cube.transparent"
        }
    }

    public var defaultColorHex: String {
        switch self {
        case .antigravity: return "#7C3AED" // Purple
        case .vsCode: return "#007ACC"      // Blue
        case .cline: return "#10B981"       // Green
        case .codex: return "#F59E0B"       // Amber
        case .cursor: return "#EC4899"      // Pink
        case .ollama: return "#6366F1"      // Indigo
        }
    }
}
