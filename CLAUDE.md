# InputFix

macOS menu bar utility that auto-restores preferred mic input when hijacked (e.g. AirPods connecting), and releases a preferred Bluetooth device when the display sleeps (reconnecting it on wake).

## Architecture

- **@Observable** `AudioDeviceManager` — single source of truth for audio. Views bind via `@Bindable`.
- **@Observable** `BluetoothManager` — single source of truth for the display-sleep Bluetooth release. Same patterns as `AudioDeviceManager`.
- **CoreAudio C APIs** — no wrappers. `AudioObjectAddPropertyListenerBlock` for device change detection, `AudioObjectSetPropertyData` to force input back.
- **IOBluetooth ObjC API** — `pairedDevices()` for enumeration, `closeConnection()` / `openConnection()` for the release. No `blueutil` dependency.
- **Display sleep detection** — there is no public API notification for display sleep (only host sleep), so `BluetoothManager` runs `/usr/bin/log stream` with predicate `category == "display" AND subsystem == "com.apple.SkyLight"` (a child `Process`) and matches `Event: Will Sleep|Event: Did Sleep` / `Event: Did Wake` in the output — the same logic as the original shell watcher. Chunks are read on a background readability handler but parsed on `.main`.
- **Menu bar only** — `LSUIElement = YES`. NSPopover shown relative to NSStatusBar button. `.transient` behavior + global event monitor for outside clicks.
- All listeners dispatch on `.main` queue — no background threading.
- `Notifier` (NotificationService.swift) — shared notification dispatch; the single `notificationsEnabled` toggle governs both features.

## Auto-Restore Flow

1. CoreAudio listener fires on `kAudioHardwarePropertyDefaultInputDevice` change
2. `handleDeviceChange()` checks: `inputLockEnabled` + current UID ≠ preferred UID
3. **0.3s delay** before `setDefaultInput()` — lets system stabilize after hijack
4. **0.1s delay** then `refreshDevices()` — syncs CoreAudio state to UI
5. Increments `restoreCount`, sends notification

The delays are empirical — removing them causes race conditions with CoreAudio.

## Display-Sleep Bluetooth Flow

1. `log stream` child process emits display power events (line-buffered in `ingest(_:)`)
2. `handleLogLine()` matches sleep/wake patterns — same strings the original awk watcher used
3. Display sleep → `handleDisplaySleep()`: guard `disconnectEnabled` + device still connected → `closeConnection()`
4. Display wake → `handleDisplayWake()`: guard `reconnectOnWake` + device not connected → `openConnection()`
5. **0.3s delay** then `refreshDevices()` — IOBluetooth state lags the call
6. Increments `toggleCount`, sends notification

One display sleep is echoed by many processes (`sharingd`, `airportd`, …) — the connectivity guards make repeated events idempotent, so `toggleCount` counts cycles, not log lines. The watcher starts/stops automatically to match `isArmed` (device selected + at least one action enabled); if `log stream` dies it restarts after 1s. `applicationWillTerminate` stops it on quit.

## UserDefaults Keys

- `preferredInputUID` (String?) — locked device UID
- `inputLockEnabled` (Bool, default true)
- `notificationsEnabled` (Bool, default false)
- `restoreCount` (Int) — lifetime auto-restore counter
- `preferredBluetoothAddress` (String?) — MAC address of device to release on display sleep
- `bluetoothDisconnectEnabled` (Bool, default true)
- `reconnectOnWake` (Bool, default true)
- `btToggleCount` (Int) — lifetime disconnect counter

Launch-at-login uses `SMAppService`, not UserDefaults.

## UI Structure

```
PopoverView
├── StatusHeaderView        # lock icon + title + dynamic subtitle (restore count)
├── FixMicButton            # shown only when unlocked + preferred device set
├── DEVICES section
│   └── DevicesCard         # lock toggle + DevicePickerView + DeviceInfoCard
├── BLUETOOTH section
│   └── BluetoothCard       # sleep-release toggle + DevicePickerView + status row + reconnect toggle
├── PREFERENCES section
│   └── PreferencesCard     # notifications + launch-at-login toggles
└── FooterView              # quit button + version tooltip
```

`SettingsCard.swift` contains `DevicesCard`, `BluetoothCard`, and `PreferencesCard`.
`Theme.swift` has all design tokens (colors, fonts, spacing, card modifier).
`DevicePickerView` is generic (keypath-based) — shared by the audio and Bluetooth cards. `collapsible: true` (Bluetooth card only) pins the selected row and hides the rest behind a "Show All N Devices" row; with nothing selected the list always shows fully.

## Build

- macOS 14.0+ (Sonoma), Xcode 15+
- Frameworks: CoreAudio, ServiceManagement, UserNotifications, SwiftUI, AppKit
- No external dependencies
- Bundle ID: `com.inputfix.app`

## Gotchas

- `isLocked` is computed (lock enabled + current == preferred) — not stored
- NSPopover height is auto-sized by SwiftUI; initial `contentSize` height (10) is ignored
- Combine is imported but unused (Observable doesn't need it)
- CoreAudio calls silently fail on error — no custom error handling
- `IOBluetoothDevice.nameOrAddress` imports as an implicitly-unwrapped optional — bind it before interpolation
- Swift can't see `+[IOBluetoothDevice deviceWithAddressString:]` — `preferredIODevice()` looks the device up in `pairedDevices()` by address instead
- One display sleep is echoed as many log lines — connectivity guards keep the actions idempotent
- `[weak self]` in all listener closures to avoid retain cycles
