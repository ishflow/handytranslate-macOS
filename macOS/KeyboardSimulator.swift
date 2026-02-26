import AppKit
import Carbon.HIToolbox

enum KeyboardSimulator {
    /// Select all (Cmd+A)
    static func selectAll() {
        sendKeyCombo(keyCode: UInt16(kVK_ANSI_A), flags: .maskCommand)
    }

    /// Copy (Cmd+C)
    static func copy() {
        sendKeyCombo(keyCode: UInt16(kVK_ANSI_C), flags: .maskCommand)
    }

    /// Paste (Cmd+V)
    static func paste() {
        sendKeyCombo(keyCode: UInt16(kVK_ANSI_V), flags: .maskCommand)
    }

    private static func sendKeyCombo(keyCode: UInt16, flags: CGEventFlags) {
        let source = CGEventSource(stateID: .hidSystemState)

        guard let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true),
              let keyUp = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false) else {
            return
        }

        keyDown.flags = flags
        keyUp.flags = flags

        keyDown.post(tap: .cghidEventTap)
        keyUp.post(tap: .cghidEventTap)
    }
}
