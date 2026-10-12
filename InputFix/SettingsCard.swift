import SwiftUI

struct DevicesCard: View {
    @Bindable var manager: AudioDeviceManager

    var body: some View {
        VStack(spacing: Theme.rowSpacing) {
            // Primary toggle — lock input
            HStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .foregroundStyle(manager.inputLockEnabled ? Theme.lockedAccent : .secondary)
                    .frame(width: Theme.iconWidth, alignment: .center)
                Text("Lock Input")
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(1)
                Spacer(minLength: 0)
                Toggle("", isOn: $manager.inputLockEnabled)
                    .toggleStyle(.switch)
                    .labelsHidden()
                    .fixedSize()
                    .tint(Theme.lockedAccent)
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 3)

            DevicePickerView(
                items: manager.inputDevices,
                name: \.name,
                itemID: \.uid,
                selectedID: $manager.preferredInputUID
            )

            DeviceInfoCard(
                isLocked: manager.isLocked,
                inputName: manager.currentInputDevice?.name ?? "None",
                outputName: manager.currentOutputDevice?.name ?? "None"
            )
        }
    }
}

struct BluetoothCard: View {
    @Bindable var manager: BluetoothManager

    var body: some View {
        VStack(spacing: Theme.rowSpacing) {
            // Primary toggle — release device on display sleep
            HStack(spacing: 8) {
                Image(systemName: "tv")
                    .foregroundStyle(manager.isArmed ? Theme.lockedAccent : .secondary)
                    .frame(width: Theme.iconWidth, alignment: .center)
                Text("Disconnect on Display Sleep")
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(1)
                Spacer(minLength: 0)
                Toggle("", isOn: $manager.disconnectEnabled)
                    .toggleStyle(.switch)
                    .labelsHidden()
                    .fixedSize()
                    .tint(Theme.lockedAccent)
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 3)

            DevicePickerView(
                items: manager.pairedDevices,
                name: \.name,
                itemID: \.id,
                selectedID: $manager.preferredAddress,
                collapsible: true
            )

            BluetoothStatusRow(device: manager.preferredDevice)

            SectionDivider()

            SettingsToggleRow(
                icon: "arrow.clockwise",
                label: "Reconnect on Wake",
                isOn: $manager.reconnectOnWake
            )
        }
    }
}

private struct BluetoothStatusRow: View {
    let device: BluetoothManager.BluetoothDevice?

    private var value: String {
        device?.isConnected == true ? "Connected" : "Disconnected"
    }

    private var valueColor: Color {
        guard let device else { return .secondary }
        return device.isConnected ? Theme.lockedAccent : Theme.unlockedAccent
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "headphones")
                .foregroundStyle(.secondary)
                .frame(width: Theme.iconWidth, alignment: .center)
            Text("Status:")
                .foregroundStyle(.secondary)
            Text(device.map(\.name) ?? "None")
                .foregroundColor(valueColor)
                .lineLimit(1)
                .truncationMode(.tail)
            Spacer(minLength: 0)
        }
        .font(Theme.bodyFont)
    }
}

struct PreferencesCard: View {
    @Bindable var manager: AudioDeviceManager

    var body: some View {
        VStack(spacing: Theme.rowSpacing) {
            SettingsToggleRow(
                icon: "bell.fill",
                label: "Notifications",
                isOn: $manager.notificationsEnabled
            )

            SettingsToggleRow(
                icon: "arrow.up.right.circle",
                label: "Launch at Login",
                isOn: $manager.launchAtLogin
            )
        }
    }
}
