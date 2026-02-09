import Foundation
import CoreAudio
import Combine
import ServiceManagement
import UserNotifications

@Observable
final class AudioDeviceManager {
    struct AudioDevice: Identifiable, Hashable {
        let id: AudioDeviceID
        let uid: String
        let name: String
        let hasInput: Bool
        let hasOutput: Bool
    }

    private(set) var inputDevices: [AudioDevice] = []
    private(set) var outputDevices: [AudioDevice] = []
    private(set) var currentInputDevice: AudioDevice?
    private(set) var currentOutputDevice: AudioDevice?

    var preferredInputUID: String? {
        didSet { UserDefaults.standard.set(preferredInputUID, forKey: "preferredInputUID") }
    }

    var inputLockEnabled: Bool = true {
        didSet { UserDefaults.standard.set(inputLockEnabled, forKey: "inputLockEnabled") }
    }

    var notificationsEnabled: Bool = false {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
            if notificationsEnabled { requestNotificationPermission() }
        }
    }

    var launchAtLogin: Bool = false {
        didSet {
            if launchAtLogin {
                try? SMAppService.mainApp.register()
            } else {
                try? SMAppService.mainApp.unregister()
            }
        }
    }

    private(set) var restoreCount: Int = 0 {
        didSet { UserDefaults.standard.set(restoreCount, forKey: "restoreCount") }
    }

    var isLocked: Bool {
        guard inputLockEnabled,
              let preferred = preferredInputUID,
              let current = currentInputDevice else { return false }
        return current.uid == preferred
    }

    var preferredDevice: AudioDevice? {
        inputDevices.first { $0.uid == preferredInputUID }
    }

    init() {
        preferredInputUID = UserDefaults.standard.string(forKey: "preferredInputUID")
        inputLockEnabled = UserDefaults.standard.object(forKey: "inputLockEnabled") as? Bool ?? true
        notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        restoreCount = UserDefaults.standard.integer(forKey: "restoreCount")
        launchAtLogin = SMAppService.mainApp.status == .enabled
        refreshDevices()
        installListeners()
    }

    // MARK: - Device Enumeration

    func refreshDevices() {
        let allDevices = Self.getAllDevices()
        inputDevices = allDevices.filter(\.hasInput)
        outputDevices = allDevices.filter(\.hasOutput)
        currentInputDevice = getDefaultDevice(forInput: true)
        currentOutputDevice = getDefaultDevice(forInput: false)
    }

    private static func getAllDevices() -> [AudioDevice] {
        var propAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        var dataSize: UInt32 = 0
        guard AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject), &propAddress, 0, nil, &dataSize) == noErr else { return [] }

        let deviceCount = Int(dataSize) / MemoryLayout<AudioDeviceID>.size
        var deviceIDs = [AudioDeviceID](repeating: 0, count: deviceCount)
        guard AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &propAddress, 0, nil, &dataSize, &deviceIDs) == noErr else { return [] }

        return deviceIDs.compactMap { deviceID in
            guard let name = getDeviceName(deviceID),
                  let uid = getDeviceUID(deviceID) else { return nil }
            let hasInput = getStreamCount(deviceID, scope: kAudioDevicePropertyScopeInput) > 0
            let hasOutput = getStreamCount(deviceID, scope: kAudioDevicePropertyScopeOutput) > 0
            guard hasInput || hasOutput else { return nil }
            return AudioDevice(id: deviceID, uid: uid, name: name, hasInput: hasInput, hasOutput: hasOutput)
        }
    }

    private static func getDeviceName(_ deviceID: AudioDeviceID) -> String? {
        var propAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyDeviceNameCFString,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var name: CFString = "" as CFString
        var dataSize = UInt32(MemoryLayout<CFString>.size)
        guard AudioObjectGetPropertyData(deviceID, &propAddress, 0, nil, &dataSize, &name) == noErr else { return nil }
        return name as String
    }

    private static func getDeviceUID(_ deviceID: AudioDeviceID) -> String? {
        var propAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyDeviceUID,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var uid: CFString = "" as CFString
        var dataSize = UInt32(MemoryLayout<CFString>.size)
        guard AudioObjectGetPropertyData(deviceID, &propAddress, 0, nil, &dataSize, &uid) == noErr else { return nil }
        return uid as String
    }

    private static func getStreamCount(_ deviceID: AudioDeviceID, scope: AudioObjectPropertyScope) -> Int {
        var propAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyStreams,
            mScope: scope,
            mElement: kAudioObjectPropertyElementMain
        )
        var dataSize: UInt32 = 0
        guard AudioObjectGetPropertyDataSize(deviceID, &propAddress, 0, nil, &dataSize) == noErr else { return 0 }
        return Int(dataSize) / MemoryLayout<AudioStreamID>.size
    }

    // MARK: - Default Device

    private func getDefaultDevice(forInput: Bool) -> AudioDevice? {
        let selector: AudioObjectPropertySelector = forInput
            ? kAudioHardwarePropertyDefaultInputDevice
            : kAudioHardwarePropertyDefaultOutputDevice

        var propAddress = AudioObjectPropertyAddress(
            mSelector: selector,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        var deviceID: AudioDeviceID = 0
        var dataSize = UInt32(MemoryLayout<AudioDeviceID>.size)
        guard AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &propAddress, 0, nil, &dataSize, &deviceID) == noErr else { return nil }

        let devices = forInput ? inputDevices : outputDevices
        return devices.first { $0.id == deviceID }
    }

    // MARK: - Set Default Input

    func setDefaultInput(device: AudioDevice) {
        var propAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var deviceID = device.id
        AudioObjectSetPropertyData(AudioObjectID(kAudioObjectSystemObject), &propAddress, 0, nil, UInt32(MemoryLayout<AudioDeviceID>.size), &deviceID)
    }

    func fixMicNow() {
        guard let preferred = preferredDevice else { return }
        setDefaultInput(device: preferred)
        // Small delay then refresh
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.refreshDevices()
        }
    }

    // MARK: - Listeners

    private func installListeners() {
        // Listen for default input device changes
        var inputAddr = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        AudioObjectAddPropertyListenerBlock(AudioObjectID(kAudioObjectSystemObject), &inputAddr, .main) { [weak self] _, _ in
            self?.handleDeviceChange()
        }

        // Listen for default output device changes
        var outputAddr = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        AudioObjectAddPropertyListenerBlock(AudioObjectID(kAudioObjectSystemObject), &outputAddr, .main) { [weak self] _, _ in
            self?.refreshDevices()
        }

        // Listen for device list changes (connect/disconnect)
        var devicesAddr = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        AudioObjectAddPropertyListenerBlock(AudioObjectID(kAudioObjectSystemObject), &devicesAddr, .main) { [weak self] _, _ in
            self?.refreshDevices()
        }
    }

    private func handleDeviceChange() {
        refreshDevices()
        guard inputLockEnabled,
              let preferredUID = preferredInputUID,
              let current = currentInputDevice,
              current.uid != preferredUID,
              let preferred = preferredDevice else { return }
        // Auto-switch back to preferred device
        let hijackerName = current.name
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.setDefaultInput(device: preferred)
            self?.restoreCount += 1
            self?.sendNotification(switched: hijackerName, to: preferred.name)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self?.refreshDevices()
            }
        }
    }

    // MARK: - Notifications

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    private func sendNotification(switched from: String, to: String) {
        guard notificationsEnabled else { return }
        let content = UNMutableNotificationContent()
        content.title = "Input Fixed"
        content.body = "\(from) → \(to)"
        content.sound = .default
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}
