import SwiftUI

struct SettingsToggleRow: View {
    let icon: String
    let label: String
    @Binding var isOn: Bool

    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: Theme.iconWidth, alignment: .center)
            Text(label)
                .font(Theme.bodyFont)
                .lineLimit(1)
            Spacer(minLength: 0)
            Toggle("", isOn: $isOn)
                .toggleStyle(.switch)
                .labelsHidden()
                .fixedSize()
                .tint(Theme.lockedAccent)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 3)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(isHovered ? Theme.hoverHighlight : .clear)
        )
        .animation(.easeInOut(duration: 0.15), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
