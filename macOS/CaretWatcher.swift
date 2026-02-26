import AppKit
import ApplicationServices

enum CaretResult: Equatable {
    case none
    case cursor
    case caret(x: CGFloat, y: CGFloat, height: CGFloat)
}

final class CaretWatcher {
    private var timer: DispatchSourceTimer?
    private let callback: (CaretResult) -> Void
    private let queue = DispatchQueue(label: "com.handytranslate.caretwatcher", qos: .userInteractive)
    private var lastResult: CaretResult = .none

    private static let textInputRoles: Set<String> = [
        "AXTextField", "AXTextArea", "AXSearchField", "AXComboBox",
        "AXWebArea", "AXGroup", "AXGenericElement"
    ]

    init(callback: @escaping (CaretResult) -> Void) {
        self.callback = callback
    }

    func start() {
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now(), repeating: .milliseconds(50))
        timer.setEventHandler { [weak self] in
            self?.poll()
        }
        timer.resume()
        self.timer = timer
    }

    func stop() {
        timer?.cancel()
        timer = nil
    }

    private func poll() {
        let result = queryCaretPosition()

        if result != lastResult {
            lastResult = result
            DispatchQueue.main.async { [weak self] in
                self?.callback(result)
            }
        }
    }

    private func queryCaretPosition() -> CaretResult {
        let systemWide = AXUIElementCreateSystemWide()
        var focusedElement: AnyObject?
        var status = AXUIElementCopyAttributeValue(systemWide, kAXFocusedUIElementAttribute as CFString, &focusedElement)

        if status != .success {
            guard let frontApp = NSWorkspace.shared.frontmostApplication else { return .none }
            let appElement = AXUIElementCreateApplication(frontApp.processIdentifier)
            status = AXUIElementCopyAttributeValue(appElement, kAXFocusedUIElementAttribute as CFString, &focusedElement)
        }

        guard status == .success, let element = focusedElement else {
            if let frontApp = NSWorkspace.shared.frontmostApplication,
               frontApp.bundleIdentifier != Bundle.main.bundleIdentifier {
                let appElement = AXUIElementCreateApplication(frontApp.processIdentifier)
                var focusedWindow: AnyObject?
                if AXUIElementCopyAttributeValue(appElement, kAXFocusedWindowAttribute as CFString, &focusedWindow) == .success {
                    return .cursor
                }
            }
            return .none
        }

        let axElement = element as! AXUIElement

        var rangeValue: AnyObject?
        let rangeStatus = AXUIElementCopyAttributeValue(axElement, kAXSelectedTextRangeAttribute as CFString, &rangeValue)

        if rangeStatus == .success, let range = rangeValue {
            var boundsValue: AnyObject?
            let boundsStatus = AXUIElementCopyParameterizedAttributeValue(
                axElement,
                kAXBoundsForRangeParameterizedAttribute as CFString,
                range,
                &boundsValue
            )

            if boundsStatus == .success, let boundsVal = boundsValue {
                var rect = CGRect.zero
                if AXValueGetValue(boundsVal as! AXValue, .cgRect, &rect) {
                    return .caret(x: rect.origin.x + rect.width, y: rect.origin.y, height: rect.height)
                }
            }

            return .cursor
        }

        var charCountValue: AnyObject?
        if AXUIElementCopyAttributeValue(axElement, kAXNumberOfCharactersAttribute as CFString, &charCountValue) == .success {
            return .cursor
        }

        var roleValue: AnyObject?
        if AXUIElementCopyAttributeValue(axElement, kAXRoleAttribute as CFString, &roleValue) == .success,
           let role = roleValue as? String,
           Self.textInputRoles.contains(role) {
            return .cursor
        }

        var valueAttr: AnyObject?
        if AXUIElementCopyAttributeValue(axElement, kAXValueAttribute as CFString, &valueAttr) == .success,
           valueAttr is String {
            return .cursor
        }

        return .none
    }

    deinit {
        stop()
    }
}
