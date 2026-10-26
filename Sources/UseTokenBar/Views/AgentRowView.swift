import SwiftUI

public struct AgentRowView: View {
    public let agent: AgentModel

    public init(agent: AgentModel) {
        self.agent = agent
    }

    public var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.purple.opacity(0.18))
                    .frame(width: 38, height: 38)
                Image(systemName: agent.provider.iconName)
                    .font(.system(size: 16))
                    .foregroundColor(.purple)
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .center, spacing: 6) {
                    Text(agent.name)
                        .font(.system(size: 13, weight: .bold))

                    // Model Badge
                    Text(agent.modelName)
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            LinearGradient(
                                colors: [Color.purple.opacity(0.25), Color.blue.opacity(0.2)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.primary)
                        .clipShape(Capsule())

                    Spacer()

                    // Status Badge
                    HStack(spacing: 4) {
                        Circle()
                            .fill(statusBadgeColor)
                            .frame(width: 6, height: 6)
                        Text(agent.state.rawValue)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(statusBadgeColor)
                    }
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(statusBadgeColor.opacity(0.12))
                    .clipShape(Capsule())
                }

                Text(agent.currentAction)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                HStack {
                    Text(agent.provider.rawValue)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(TokenStats.formattedNumber(agent.tokensSession)) tokens acumulados")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(.primary)
                }
            }
        }
        .padding(10)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.7))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
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
