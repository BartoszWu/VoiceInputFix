import SwiftUI

struct VisualEffectBackground: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .popover
        view.blendingMode = .behindWindow
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}

struct PopoverView: View {
    @Bindable var manager: AudioDeviceManager

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Status header
            StatusHeaderView(
                isLocked: manager.isLocked,
                currentInputName: manager.currentInputDevice?.name ?? "Unknown",
                preferredInputName: manager.preferredDevice?.name
            )

            // Fix Mic CTA (unlocked only)
            if !manager.isLocked && manager.preferredDevice != nil {
                Button(action: { manager.fixMicNow() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "bolt.fill")
                        Text("Fix Mic Now")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)
            }

            SectionDivider()

            // Device info
            DeviceInfoCard(
                isLocked: manager.isLocked,
                inputName: manager.currentInputDevice?.name ?? "None",
                outputName: manager.currentOutputDevice?.name ?? "None"
            )

            SectionDivider()

            // Settings
            SettingsCard(manager: manager)

            Divider()
                .padding(.vertical, Theme.sectionGap)

            // Footer
            FooterView()
        }
        .padding(Theme.outerPadding)
        .frame(width: Theme.popoverWidth)
        .background(VisualEffectBackground())
    }
}
