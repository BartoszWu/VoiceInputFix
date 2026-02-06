import SwiftUI

struct DevicePickerView: View {
    let devices: [AudioDeviceManager.AudioDevice]
    @Binding var selectedUID: String?

    var body: some View {
        Picker("Preferred Input", selection: $selectedUID) {
            Text("None").tag(String?.none)
            ForEach(devices) { device in
                Text(device.name).tag(Optional(device.uid))
            }
        }
        .pickerStyle(.menu)
    }
}
