#!/usr/bin/env swift
import AppKit
import Foundation

// Apps where held keys should repeat instead of showing the accent menu.
// Everything else keeps the accent menu (global press-and-hold on).
let keyRepeatApps: Set<String> = [
    "com.todesktop.230313mzl4w4u92" // Cursor
]

let prefKey = "ApplePressAndHoldEnabled" as CFString

func setGlobalPressAndHold(_ enabled: Bool) {
    let current = CFPreferencesCopyAppValue(prefKey, kCFPreferencesAnyApplication) as? Bool
    if current == enabled { return }

    CFPreferencesSetValue(
        prefKey,
        enabled as CFBoolean,
        kCFPreferencesAnyApplication,
        kCFPreferencesCurrentUser,
        kCFPreferencesAnyHost
    )
    CFPreferencesSynchronize(
        kCFPreferencesAnyApplication,
        kCFPreferencesCurrentUser,
        kCFPreferencesAnyHost
    )

    FileHandle.standardOutput.write(
        "[\(Date())] set global=\(enabled)\n".data(using: .utf8)!
    )
}

func handle(_ note: Notification) {
    guard
        let app = note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
        let bundle = app.bundleIdentifier
    else { return }
    setGlobalPressAndHold(!keyRepeatApps.contains(bundle))
}

let nc = NSWorkspace.shared.notificationCenter
nc.addObserver(
    forName: NSWorkspace.didActivateApplicationNotification,
    object: nil, queue: .main, using: handle
)
nc.addObserver(
    forName: NSWorkspace.didLaunchApplicationNotification,
    object: nil, queue: .main, using: handle
)

// Sync with whatever is frontmost right now.
if let front = NSWorkspace.shared.frontmostApplication,
   let bundle = front.bundleIdentifier {
    setGlobalPressAndHold(!keyRepeatApps.contains(bundle))
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
app.run()
