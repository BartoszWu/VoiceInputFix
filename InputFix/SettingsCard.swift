import SwiftUI

struct SettingsCard: View {
    @Bindable var manager: AudioDeviceManager

    var body: some View {
        VStack(spacing: Theme.rowSpacing) {
            // Primary controls
            SettingsToggleRow(
                icon: "shield.fill",
                label: "Auto-Anchor Protection",
                isOn: $manager.inputLockEnabled
            )

            DevicePickerView(
                devices: manager.inputDevices,
                selectedUID: $manager.preferredInputUID
            )

            Divider()
                .padding(.vertical, 2)

            // Secondary controls
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
        .padding(Theme.groupPadding)
        .background(
            RoundedRectangle(cornerRadius: Theme.groupRadius)
                .fill(Theme.groupBackground)
        )
    }
}
