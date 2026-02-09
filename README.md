# InputFix

A lightweight macOS menu bar utility that prevents unwanted microphone input switching. When AirPods connect or another device tries to hijack your mic, InputFix automatically switches back to your preferred input device.

## Features

- **Auto-Anchor Protection** — Locks input to your preferred microphone and auto-reverts if another device takes over
- **Manual Fix** — One-click "Fix Mic Now" button to instantly revert input
- **Notifications** — Alerts when a mic switch is detected and corrected
- **Launch at Login** — Start automatically via macOS Login Items
- **Light & Dark Mode** — Adaptive UI with status-colored accents (green = locked, orange = unlocked)

## Requirements

- macOS 14.0+ (Sonoma)
- Xcode 15.0+

No external dependencies. Uses CoreAudio, ServiceManagement, and UserNotifications frameworks.

## Build & Run

### Xcode

Open `InputFix.xcodeproj` and press **Cmd+R**.

### Terminal

```bash
xcodebuild -project InputFix.xcodeproj -scheme InputFix -configuration Debug SYMROOT="$(pwd)/build" build
open build/Debug/InputFix.app
```

## How It Works

1. InputFix lives in the menu bar (no Dock icon)
2. Click the status icon to open the popover
3. Select your preferred input device from the picker
4. Enable **Auto-Anchor Protection**
5. When another device tries to claim the input (e.g., AirPods connecting), InputFix detects the change via CoreAudio listeners and switches back automatically

Settings are persisted via UserDefaults.

## Project Structure

```
InputFix/
├── InputFixApp.swift          # App entry, status bar & popover setup
├── AudioDeviceManager.swift   # CoreAudio device control & auto-lock logic
├── PopoverView.swift          # Main UI container & Fix Mic button
├── StatusHeaderView.swift     # Lock status header
├── DeviceInfoCard.swift       # Current input/output device display
├── DevicePickerView.swift     # Input device selector
├── SettingsCard.swift         # Settings section with toggles & picker
├── SettingsToggleRow.swift    # Reusable toggle row component
├── Theme.swift                # Design tokens (colors, fonts, spacing)
├── FooterView.swift           # Quit button & version
└── SectionDivider.swift       # Section divider component
```
