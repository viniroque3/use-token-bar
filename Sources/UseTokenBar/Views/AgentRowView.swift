import SwiftUI

public struct AgentRowView: View {
    public let agent: AgentModel

    public init(agent: AgentModel) {
        self.agent = agent
    }

    private let appleBlue = Color(red: 0.0, green: 0.478, blue: 1.0)

    public var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(appleBlue.opacity(0.08))
                    .frame(width: 38, height: 38)
                Image(systemName: agent.provider.iconName)
                    .font(.system(size: 16))
                    .foregroundColor(appleBlue)
            }

            // Info
            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .center, spacing: 8) {
                    Text(agent.name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(red: 0.12, green: 0.12, blue: 0.14))

                    Text(agent.modelName)
                        .font(.system(size: 10, weight: .medium))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.black.opacity(0.04))
                        .foregroundColor(Color(red: 0.35, green: 0.35, blue: 0.38))
                        .cornerRadius(6)

                    Spacer()

                    // Minimal status indicator without pill shape
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
                    .foregroundColor(Color(red: 0.55, green: 0.55, blue: 0.58))
                    .lineLimit(1)

                HStack {
                    Text(agent.provider.rawValue)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(red: 0.55, green: 0.55, blue: 0.58))
                    Spacer()
                    Text("\(TokenStats.formattedNumber(agent.tokensSession)) tokens")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(red: 0.25, green: 0.25, blue: 0.28))
                }
            }
        }
        .padding(11)
        .background(Color(red: 0.975, green: 0.978, blue: 0.985))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
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
