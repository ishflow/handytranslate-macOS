import AppKit
import Shared

final class StatusBarController {
    private let statusItem: NSStatusItem
    private let onSettings: () -> Void
    private let onQuit: () -> Void

    init(
        onSettings: @escaping () -> Void,
        onQuit: @escaping () -> Void
    ) {
        self.onSettings = onSettings
        self.onQuit = onQuit

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "translate", accessibilityDescription: "HandyTranslate")
        }

        statusItem.menu = buildMenu()
    }

    func updateState(_ state: TranslationState) {
        guard let button = statusItem.button else { return }
        switch state {
        case .idle:
            button.image = NSImage(systemSymbolName: "translate", accessibilityDescription: "HandyTranslate")
        case .loading:
            button.image = NSImage(systemSymbolName: "arrow.trianglehead.2.clockwise", accessibilityDescription: "Translating...")
        case .done:
            button.image = NSImage(systemSymbolName: "checkmark.circle.fill", accessibilityDescription: "Done")
        case .error:
            button.image = NSImage(systemSymbolName: "exclamationmark.triangle.fill", accessibilityDescription: "Error")
        }
    }

    private func buildMenu() -> NSMenu {
        let menu = NSMenu()

        let shortcutInfo = NSMenuItem(title: "Translate: ⌘⇧⌥M", action: nil, keyEquivalent: "")
        shortcutInfo.isEnabled = false
        menu.addItem(shortcutInfo)

        menu.addItem(.separator())

        let settingsItem = NSMenuItem(title: "Settings…", action: #selector(settingsAction), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit HandyTranslate", action: #selector(quitAction), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        return menu
    }

    @objc private func settingsAction() {
        onSettings()
    }

    @objc private func quitAction() {
        onQuit()
    }
}
