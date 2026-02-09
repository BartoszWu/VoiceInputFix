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

struct FixMicButton: View {
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "bolt.fill")
                Text("Fix Mic Now")
                    .font(Theme.buttonFont)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 34)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.72, blue: 0.2),
                        Color(red: 0.95, green: 0.58, blue: 0.12)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .shadow(color: .black.opacity(0.12), radius: 2, y: 1)
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .transition(.move(edge: .top).combined(with: .opacity))
    }
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
                FixMicButton(action: { manager.fixMicNow() })
                    .padding(.top, 10)
            }

            // DEVICES section
            VStack(alignment: .leading, spacing: 6) {
                Text("DEVICES")
                    .font(Theme.sectionLabel)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 2)

                DeviceInfoCard(
                    isLocked: manager.isLocked,
                    inputName: manager.currentInputDevice?.name ?? "None",
                    outputName: manager.currentOutputDevice?.name ?? "None"
                )
                .cardStyle()
            }
            .padding(.top, Theme.cardSpacing + 4)

            // SETTINGS section
            VStack(alignment: .leading, spacing: 6) {
                Text("SETTINGS")
                    .font(Theme.sectionLabel)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 2)

                SettingsCard(manager: manager)
                    .cardStyle()
            }
            .padding(.top, Theme.cardSpacing)

            // Footer
            FooterView()
                .padding(.top, Theme.cardSpacing + 2)
        }
        .padding(Theme.outerPadding)
        .frame(width: Theme.popoverWidth)
        .background(VisualEffectBackground())
    }
}
