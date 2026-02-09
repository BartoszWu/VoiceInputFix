# InputFix

macOS menu bar utility that auto-restores preferred mic input when hijacked (e.g. AirPods connecting).

## Architecture

- **@Observable** `AudioDeviceManager` — single source of truth. Views bind via `@Bindable`.
- **CoreAudio C APIs** — no wrappers. `AudioObjectAddPropertyListenerBlock` for device change detection, `AudioObjectSetPropertyData` to force input back.
- **Menu bar only** — `LSUIElement = YES`. NSPopover shown relative to NSStatusBar button. `.transient` behavior + global event monitor for outside clicks.
- All listeners dispatch on `.main` queue — no background threading.

## Auto-Restore Flow

1. CoreAudio listener fires on `kAudioHardwarePropertyDefaultInputDevice` change
2. `handleDeviceChange()` checks: `inputLockEnabled` + current UID ≠ preferred UID
3. **0.3s delay** before `setDefaultInput()` — lets system stabilize after hijack
4. **0.1s delay** then `refreshDevices()` — syncs CoreAudio state to UI
5. Increments `restoreCount`, sends notification

The delays are empirical — removing them causes race conditions with CoreAudio.

## UserDefaults Keys

- `preferredInputUID` (String?) — locked device UID
- `inputLockEnabled` (Bool, default true)
- `notificationsEnabled` (Bool, default false)
- `restoreCount` (Int) — lifetime auto-restore counter

Launch-at-login uses `SMAppService`, not UserDefaults.

## UI Structure

```
PopoverView
├── StatusHeaderView        # lock icon + title + dynamic subtitle (restore count)
├── FixMicButton            # shown only when unlocked + preferred device set
├── DEVICES section
│   └── DevicesCard         # lock toggle + DevicePickerView + DeviceInfoCard
├── PREFERENCES section
│   └── PreferencesCard     # notifications + launch-at-login toggles
└── FooterView              # quit button + version tooltip
```

`SettingsCard.swift` contains both `DevicesCard` and `PreferencesCard`.
`Theme.swift` has all design tokens (colors, fonts, spacing, card modifier).

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
- `[weak self]` in all listener closures to avoid retain cycles
