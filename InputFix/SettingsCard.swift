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
                devices: manager.inputDevices,
                selectedUID: $manager.preferredInputUID
            )

            DeviceInfoCard(
                isLocked: manager.isLocked,
                inputName: manager.currentInputDevice?.name ?? "None",
                outputName: manager.currentOutputDevice?.name ?? "None"
            )
        }
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
