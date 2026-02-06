import SwiftUI

struct FooterView: View {
    var body: some View {
        HStack(spacing: 6) {
            Button(action: { NSApplication.shared.terminate(nil) }) {
                HStack(spacing: 4) {
                    Image(systemName: "power")
                    Text("Quit InputFix")
                }
                .font(Theme.captionFont)
                .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)

            Spacer()
        }
    }
}
