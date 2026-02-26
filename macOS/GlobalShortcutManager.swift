import AppKit
import Carbon.HIToolbox

final class GlobalShortcutManager {
    private let action: () -> Void
    private var hotKeyRef: EventHotKeyRef?
    private static var shared: GlobalShortcutManager?

    init(action: @escaping () -> Void) {
        self.action = action
    }

    func register() {
        GlobalShortcutManager.shared = self

        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))

        InstallEventHandler(
            GetApplicationEventTarget(),
            { (_, event, _) -> OSStatus in
                guard let manager = GlobalShortcutManager.shared else { return noErr }
                DispatchQueue.main.async {
                    manager.action()
                }
                return noErr
            },
            1,
            &eventType,
            nil,
            nil
        )

        // Cmd+Shift+Option+M
        let modifiers = UInt32(cmdKey | shiftKey | optionKey)
        let keyCode = UInt32(kVK_ANSI_M)
        let hotKeyID = EventHotKeyID(signature: OSType(0x48545254), id: 1)

        let status = RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
    }

    func unregister() {
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
            hotKeyRef = nil
        }
        GlobalShortcutManager.shared = nil
    }

    deinit {
        unregister()
    }
}
