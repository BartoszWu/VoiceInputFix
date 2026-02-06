import SwiftUI

struct DeviceInfoCard: View {
    let isLocked: Bool
    let inputName: String
    let outputName: String

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.rowSpacing) {
            deviceRow(
                icon: "mic.fill",
                label: "Input:",
                value: inputName,
                valueColor: isLocked ? .primary : Theme.unlockedAccent
            )
            deviceRow(
                icon: "headphones",
                label: "Output:",
                value: outputName,
                valueColor: .secondary
            )
        }
    }

    private func deviceRow(icon: String, label: String, value: String, valueColor: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: Theme.iconWidth, alignment: .center)
            Text(label)
                .foregroundStyle(.secondary)
            Text(value)
                .foregroundColor(valueColor)
                .lineLimit(1)
                .truncationMode(.tail)
            Spacer(minLength: 0)
        }
        .font(Theme.bodyFont)
    }
}
