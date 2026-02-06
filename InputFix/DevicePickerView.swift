import SwiftUI

struct DevicePickerView: View {
    let devices: [AudioDeviceManager.AudioDevice]
    @Binding var selectedUID: String?

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "arrow.down.circle")
                .foregroundStyle(.secondary)
                .frame(width: Theme.iconWidth, alignment: .center)
            Text("Preferred Input")
                .font(Theme.bodyFont)

            Spacer()

            Picker("", selection: $selectedUID) {
                Text("None").tag(String?.none)
                ForEach(devices) { device in
                    Text(device.name).tag(Optional(device.uid))
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .font(Theme.bodyFont)
        }
    }
}
