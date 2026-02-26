import AppKit
import SwiftUI
import Shared

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarController: StatusBarController!
    private var globalShortcutManager: GlobalShortcutManager!
    private var translationCoordinator: TranslationCoordinator!

    let settings = AppSettings()

    private var settingsWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize translation coordinator
        translationCoordinator = TranslationCoordinator(settings: settings)

        // Initialize status bar
        statusBarController = StatusBarController(
            onSettings: { [weak self] in
                self?.showSettings()
            },
            onQuit: {
                NSApp.terminate(nil)
            }
        )

        // Connect coordinator state to status bar icon
        translationCoordinator.onStateChanged = { [weak self] state in
            self?.statusBarController.updateState(state)
        }

        // Initialize global shortcut (Cmd+Shift+Option+M)
        globalShortcutManager = GlobalShortcutManager { [weak self] in
            self?.translationCoordinator.performTranslation()
        }
        globalShortcutManager.register()
    }

    func showSettings() {
        if let existing = settingsWindow {
            existing.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let settingsView = SettingsView(settings: settings)
        let hostingController = NSHostingController(rootView: settingsView)

        let window = NSWindow(contentViewController: hostingController)
        window.title = "HandyTranslate Settings"
        window.styleMask = [.titled, .closable]
        window.setContentSize(NSSize(width: 400, height: 200))
        window.center()
        window.isReleasedWhenClosed = false
        window.delegate = self

        self.settingsWindow = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationWillTerminate(_ notification: Notification) {
        globalShortcutManager?.unregister()
    }
}

extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        settingsWindow = nil
    }
}
