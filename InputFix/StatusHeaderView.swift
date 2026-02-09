import SwiftUI

struct StatusHeaderView: View {
    let isLocked: Bool
    let currentInputName: String
    let preferredInputName: String?

    private var accent: Color { Theme.accent(locked: isLocked) }

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
                        .truncationMode(.tail)
                } else {
                    Text("Input Unlocked")
                        .font(Theme.titleFont)
                }

                Text(isLocked ? "Protection is active." : "Input lock is off.")
                    .font(Theme.captionFont)
                    .foregroundStyle(isLocked ? .secondary : Theme.unlockedAccent)
            }

            Spacer(minLength: 0)
        }
    }
}
