import SwiftUI

struct SettingsToggleRow: View {
    let icon: String
    let label: String
    @Binding var isOn: Bool

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
        }
    }
}
