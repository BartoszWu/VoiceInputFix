import SwiftUI

@main
struct InputFixApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings { EmptyView() }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate {
    private var statusItem: NSStatusItem!
    private let popover = NSPopover()
    private let manager = AudioDeviceManager()
    private var eventMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Setup status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "mic.badge.xmark", accessibilityDescription: "InputFix")
            button.action = #selector(togglePopover)
            button.target = self
        }

        // Setup popover
        popover.contentSize = NSSize(width: 280, height: 380)
        popover.behavior = .transient
        popover.delegate = self
        popover.contentViewController = NSHostingController(rootView: PopoverView(manager: manager))

        // Close popover when clicking outside
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            self?.popover.performClose(nil)
        }
    }

    @objc private func togglePopover() {
        if popover.isShown {
            popover.performClose(nil)
        } else if let button = statusItem.button {
            // Refresh devices before showing
            manager.refreshDevices()
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            // Ensure popover window can become key
            popover.contentViewController?.view.window?.makeKey()
        }
    }
}
