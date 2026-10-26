import SwiftUI

public struct AgentRowView: View {
    public let agent: AgentModel

    public init(agent: AgentModel) {
        self.agent = agent
    }

    public var body: some View {
        HStack(alignment: .center, spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: agent.provider.iconName)
                    .font(.system(size: 14))
                    .foregroundColor(.accentColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(agent.name)
                        .font(.system(size: 12, weight: .bold))
                    Spacer()
                    Text(agent.state.rawValue)
                        .font(.system(size: 10, weight: .medium))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(statusBadgeColor.opacity(0.15))
                        .foregroundColor(statusBadgeColor)
                        .clipShape(Capsule())
                }

                Text(agent.currentAction)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                HStack {
                    Text(agent.provider.rawValue)
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(TokenStats.formattedNumber(agent.tokensSession)) tokens")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(.primary)
                }
            }
        }
        .padding(8)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.6))
        .cornerRadius(8)
    }

    private var statusBadgeColor: Color {
        switch agent.state {
        case .generating: return .green
        case .executingTool: return .orange
        case .waitingInput: return .blue
        case .idle: return .gray
        }
    }
}
