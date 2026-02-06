import SwiftUI

struct PopoverView: View {
    @Bindable var manager: AudioDeviceManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Status header
            StatusHeaderView(
                isLocked: manager.isLocked,
                currentInputName: manager.currentInputDevice?.name ?? "Unknown"
            )

            // Fix Mic Now button (only when not locked and has a preferred device)
            if !manager.isLocked && manager.preferredDevice != nil {
                Button(action: { manager.fixMicNow() }) {
                    HStack {
                        Image(systemName: "bolt.fill")
                        Text("Fix Mic Now")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
            }

            Divider()

            // Current devices info
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "mic.fill")
                        .foregroundColor(manager.isLocked ? .primary : .orange)
                        .frame(width: 16)
                    Text("Input:")
                        .foregroundStyle(.secondary)
                    Text(manager.currentInputDevice?.name ?? "None")
                        .foregroundColor(manager.isLocked ? .primary : .orange)
                        .lineLimit(1)
                }
                .font(.system(size: 12))

                HStack(spacing: 6) {
                    Image(systemName: "headphones")
                        .foregroundStyle(.secondary)
                        .frame(width: 16)
                    Text("Output:")
                        .foregroundStyle(.secondary)
                    Text(manager.currentOutputDevice?.name ?? "None")
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                .font(.system(size: 12))
            }

            Divider()

            // Input Lock toggle
            Toggle("Input Lock", isOn: $manager.inputLockEnabled)
                .toggleStyle(.switch)
                .font(.system(size: 12, weight: .medium))

            // Device picker
            DevicePickerView(
                devices: manager.inputDevices,
                selectedUID: $manager.preferredInputUID
            )
            .font(.system(size: 12))

            Toggle("Notifications", isOn: $manager.notificationsEnabled)
                .toggleStyle(.switch)
                .font(.system(size: 12, weight: .medium))

            Toggle("Launch at Login", isOn: $manager.launchAtLogin)
                .toggleStyle(.switch)
                .font(.system(size: 12, weight: .medium))

            Divider()

            Button("Quit InputFix") {
                NSApplication.shared.terminate(nil)
            }
            .font(.system(size: 12))
            .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(width: 280)
    }
}
