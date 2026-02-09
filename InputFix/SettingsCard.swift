import SwiftUI

struct SettingsCard: View {
    @Bindable var manager: AudioDeviceManager

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: Theme.rowSpacing) {
                SettingsToggleRow(
                    icon: "shield.fill",
                    label: "Auto-Anchor Protection",
                    isOn: $manager.inputLockEnabled
                )

                DevicePickerView(
                    devices: manager.inputDevices,
                    selectedUID: $manager.preferredInputUID
                )
            }

            Rectangle()
                .fill(Color.primary.opacity(0.06))
                .frame(height: 0.5)
                .padding(.vertical, 20)

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
}
