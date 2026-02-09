import SwiftUI

struct FooterView: View {
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.primary.opacity(0.08))
                .frame(height: 0.5)
                .padding(.bottom, 10)

            HStack(spacing: 4) {
                Button(action: { NSApplication.shared.terminate(nil) }) {
                    HStack(spacing: 4) {
                        Image(systemName: "power")
                        Text("Quit InputFix")
                    }
                    .font(Theme.captionFont)
                    .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .onHover { hovering in
                    if hovering {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pop()
                    }
                }

                Spacer()

                Image(systemName: "info.circle")
                    .font(Theme.captionFont)
                    .foregroundStyle(.tertiary)
                    .help("InputFix v1.0")
            }
        }
    }
}
