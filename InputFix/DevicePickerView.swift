import SwiftUI

struct DevicePickerView: View {
    let devices: [AudioDeviceManager.AudioDevice]
    @Binding var selectedUID: String?

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "arrow.down.circle")
                .foregroundStyle(.secondary)
                .frame(width: Theme.iconWidth, alignment: .center)
            Text("Input Device")
                .font(Theme.bodyFont)
                .lineLimit(1)

            Spacer(minLength: 4)

            Picker("", selection: $selectedUID) {
                Text("None").tag(String?.none)
                ForEach(devices) { device in
                    Text(device.name).tag(Optional(device.uid))
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .font(Theme.bodyFont)
            .background(
                Capsule()
                    .fill(Theme.cardBackground)
                    .overlay(
                        Capsule()
                            .strokeBorder(Theme.cardBorder, lineWidth: 0.5)
                    )
            )
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 3)
    }
}
