import SwiftUI

struct StatusHeaderView: View {
    let isLocked: Bool
    let currentInputName: String
    let preferredInputName: String?
    let restoreCount: Int

    private var accent: Color { Theme.accent(locked: isLocked) }

    private var subtitle: String {
        guard isLocked else { return "Input lock is off." }
        switch restoreCount {
        case 0: return "Auto-restores if changed."
        case 1: return "Auto-restored 1 time."
        default: return "Auto-restored \(restoreCount) times."
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(accent.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: isLocked ? "lock.fill" : "lock.open.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(accent)
                    .symbolEffect(.bounce, value: isLocked)
            }

            VStack(alignment: .leading, spacing: 2) {
                if isLocked, let preferred = preferredInputName {
                    Text("Input Locked to \(preferred)")
                        .font(Theme.titleFont)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                } else {
                    Text("Input Unlocked")
                        .font(Theme.titleFont)
                }

                Text(subtitle)
                    .font(Theme.captionFont)
                    .foregroundStyle(
                        isLocked && restoreCount >= 10
                            ? Theme.lockedAccent.opacity(0.8)
                            : isLocked ? .secondary : Theme.unlockedAccent
                    )
            }

            Spacer(minLength: 0)
        }
    }
}
