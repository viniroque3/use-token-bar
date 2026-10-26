import SwiftUI

public struct AgentRowView: View {
    public let agent: AgentModel

    public init(agent: AgentModel) {
        self.agent = agent
    }

    private let textPrimary = Color(red: 0.11, green: 0.11, blue: 0.13)
    private let textSecondary = Color(red: 0.55, green: 0.55, blue: 0.58)

    public var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(alignment: .center, spacing: 8) {
                Text(agent.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(textPrimary)

                Text(agent.modelName)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(textSecondary)

                Spacer()

                HStack(spacing: 5) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 6, height: 6)
                    Text(agent.state.rawValue)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(statusColor)
                }
            }

            Text(agent.currentAction)
                .font(.system(size: 11))
                .foregroundColor(textSecondary)
                .lineLimit(1)

            HStack {
                Text(agent.provider.rawValue)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(textSecondary)
                Spacer()
                Text("\(TokenStats.formattedNumber(agent.tokensSession)) tokens")
                    .font(.system(size: 11, weight: .light, design: .rounded))
                    .foregroundColor(Color(red: 0.0, green: 0.478, blue: 1.0))
            }

            Divider()
                .padding(.top, 4)
        }
        .padding(.vertical, 3)
    }

    private var statusColor: Color {
        switch agent.state {
        case .generating: return Color(red: 0.20, green: 0.78, blue: 0.35)
        case .executingTool: return Color(red: 1.0, green: 0.58, blue: 0.0)
        case .waitingInput: return Color(red: 0.0, green: 0.478, blue: 1.0)
        case .idle: return Color(red: 0.60, green: 0.60, blue: 0.65)
        }
    }
}
