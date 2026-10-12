import Foundation
import IOBluetooth

/// Watches macOS display power events and releases the preferred Bluetooth
/// device when the display sleeps, reconnecting it on wake — the logic of
/// macos-bluetooth-disconnect-on-display-sleep, ported natively.
///
/// Display sleep has no public API notification, so (like the shell watcher)
/// we stream the unified log for the SkyLight events the system itself emits
/// when the screen goes black, and match the same "Event: Did Sleep" /
/// "Event: Did Wake" lines. This is event-driven: no polling, no idle-time
/// heuristics, no false positives when an app keeps the display awake.
@Observable
final class BluetoothManager {
    struct BluetoothDevice: Identifiable, Hashable {
        let id: String          // Bluetooth MAC address, e.g. "aa-bb-cc-dd-ee-ff"
        let name: String
        let isConnected: Bool
    }

    private(set) var pairedDevices: [BluetoothDevice] = []
    private(set) var preferredDevice: BluetoothDevice?

    var preferredAddress: String? {
        didSet {
            UserDefaults.standard.set(preferredAddress, forKey: "preferredBluetoothAddress")
            preferredDevice = pairedDevices.first { $0.id == preferredAddress }
            updateWatcher()
        }
    }

    var disconnectEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(disconnectEnabled, forKey: "bluetoothDisconnectEnabled")
            updateWatcher()
        }
    }

    var reconnectOnWake: Bool = true {
        didSet { UserDefaults.standard.set(reconnectOnWake, forKey: "reconnectOnWake") }
    }

    private(set) var toggleCount: Int = 0 {
        didSet { UserDefaults.standard.set(toggleCount, forKey: "btToggleCount") }
    }

    var isWatcherActive: Bool { logProcess != nil }

    /// True when the display watcher should run: a device is selected and at
    /// least one of the sleep/wake actions is enabled.
    var isArmed: Bool {
        guard preferredAddress != nil else { return false }
        return disconnectEnabled || reconnectOnWake
    }

    private var logProcess: Process?
    private var lineBuffer = ""

    /// Same predicate the shell watcher used — the system's display power log.
    private static let logPredicate = "category == \"display\" AND subsystem == \"com.apple.SkyLight\""

    init() {
        preferredAddress = UserDefaults.standard.string(forKey: "preferredBluetoothAddress")
        disconnectEnabled = UserDefaults.standard.object(forKey: "bluetoothDisconnectEnabled") as? Bool ?? true
        reconnectOnWake = UserDefaults.standard.bool(forKey: "reconnectOnWake")
        toggleCount = UserDefaults.standard.integer(forKey: "btToggleCount")
        refreshDevices()
        updateWatcher()
    }

    // MARK: - Device Enumeration

    func refreshDevices() {
        let devices = (IOBluetoothDevice.pairedDevices() as? [IOBluetoothDevice]) ?? []
        pairedDevices = devices.compactMap { device in
            guard let address = device.addressString else { return nil }
            return BluetoothDevice(id: address, name: device.nameOrAddress, isConnected: device.isConnected())
        }
        .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        preferredDevice = pairedDevices.first { $0.id == preferredAddress }
    }

    private func preferredIODevice() -> IOBluetoothDevice? {
        guard let preferredAddress else { return nil }
        return (IOBluetoothDevice.pairedDevices() as? [IOBluetoothDevice])?
            .first { $0.addressString == preferredAddress }
    }

    // MARK: - Display Sleep / Wake

    private func handleDisplaySleep() {
        guard disconnectEnabled,
              let device = preferredIODevice(),
              device.isConnected() else { return }
        device.closeConnection()
        toggleCount += 1
        Notifier.send(title: "Bluetooth Released", body: "\(device.nameOrAddress ?? "Device") disconnected — display asleep")
        scheduleRefresh()
    }

    private func handleDisplayWake() {
        guard reconnectOnWake,
              let device = preferredIODevice(),
              !device.isConnected() else { return }
        device.openConnection()
        Notifier.send(title: "Bluetooth Reconnected", body: "\(device.nameOrAddress ?? "Device") reconnected — display awake")
        scheduleRefresh()
    }

    private func scheduleRefresh() {
        // Same settle delay as the audio restore flow — IOBluetooth state
        // lags the connection call just like CoreAudio does.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.refreshDevices()
        }
    }

    // MARK: - Display Watcher

    private func updateWatcher() {
        if isArmed { startWatcher() } else { stopWatcher() }
    }

    private func startWatcher() {
        guard logProcess == nil else { return }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/log")
        process.arguments = ["stream", "--predicate", Self.logPredicate, "--style", "compact"]
        process.standardError = FileHandle.nullDevice

        let pipe = Pipe()
        process.standardOutput = pipe
        pipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            guard !data.isEmpty else {
                handle.readabilityHandler = nil
                return
            }
            DispatchQueue.main.async { [weak self] in
                self?.ingest(data)
            }
        }

        do {
            try process.run()
        } catch {
            pipe.fileHandleForReading.readabilityHandler = nil
            return
        }

        // If log stream dies (e.g. logd restart), bring the watcher back.
        process.terminationHandler = { [weak self] _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self, self.isArmed, self.logProcess == nil else { return }
                self.startWatcher()
            }
        }

        lineBuffer = ""
        logProcess = process
    }

    /// Stops the log watcher. Called by the app delegate on quit.
    func stopWatcher() {
        guard let process = logProcess else { return }
        if let pipe = process.standardOutput as? Pipe {
            pipe.fileHandleForReading.readabilityHandler = nil
        }
        process.terminationHandler = nil
        if process.isRunning { process.terminate() }
        logProcess = nil
        lineBuffer = ""
    }

    private func ingest(_ data: Data) {
        guard let text = String(data: data, encoding: .utf8) else { return }
        lineBuffer += text
        while let newline = lineBuffer.firstIndex(of: "\n") {
            let line = String(lineBuffer[..<newline])
            lineBuffer.removeSubrange(...newline)
            handleLogLine(line)
        }
    }

    /// Same patterns the shell watcher matched — substring anywhere in the
    /// compact log line, exactly what the awk regexes did.
    private func handleLogLine(_ line: String) {
        if line.contains("Event: Will Sleep") || line.contains("Event: Did Sleep") {
            handleDisplaySleep()
        } else if line.contains("Event: Did Wake") {
            handleDisplayWake()
        }
    }
}
