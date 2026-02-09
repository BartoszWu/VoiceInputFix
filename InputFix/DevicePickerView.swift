import SwiftUI

struct DevicePickerView: View {
    let devices: [AudioDeviceManager.AudioDevice]
    @Binding var selectedUID: String?

    var body: some View {
        VStack(spacing: 2) {
            ForEach(devices) { device in
                DevicePickerRow(
                    name: device.name,
                    isSelected: device.uid == selectedUID
                ) {
                    selectedUID = device.uid
                }
            }
        }
    }
}

private struct DevicePickerRow: View {
    let name: String
    let isSelected: Bool
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(isSelected ? Theme.lockedAccent : Color.secondary.opacity(0.4))
                    .frame(width: 16, alignment: .center)

                Text(name)
                    .font(Theme.bodyFont)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(isHovered ? Theme.hoverHighlight : .clear)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
