import SwiftUI

struct FooterView: View {
    var body: some View {
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

            Text("v1.0")
                .font(Theme.captionFont)
                .foregroundStyle(.tertiary)
        }
    }
}
