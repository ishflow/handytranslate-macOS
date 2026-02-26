import AppKit
import Shared

final class FloatingPanelController {
    private let panel: FloatingPanel
    private let dotView: FloatingDotView
    private var hideWorkItem: DispatchWorkItem?
    private var isVisible = false
    private var cursorSnapPoint: NSPoint?
    private var lastMode: CaretResult = .none

    var onDotClicked: (() -> Void)? {
        get { dotView.onClick }
        set { dotView.onClick = newValue }
    }

    var state: TranslationState {
        get { dotView.state }
        set { dotView.state = newValue }
    }

    init() {
        let dotSize: CGFloat = 17 // 13px dot + padding
        panel = FloatingPanel(contentRect: NSRect(x: 0, y: 0, width: dotSize, height: dotSize))
        dotView = FloatingDotView(frame: NSRect(x: 0, y: 0, width: dotSize, height: dotSize))
        panel.contentView = dotView
    }

    func update(caretResult: CaretResult) {
        hideWorkItem?.cancel()
        hideWorkItem = nil

        let wasInCursorMode: Bool
        if case .cursor = lastMode { wasInCursorMode = true } else { wasInCursorMode = false }
        lastMode = caretResult

        switch caretResult {
        case .caret(let x, let y, let height):
            cursorSnapPoint = nil
            let screenPoint = axToAppKit(axX: x + 8, axY: y, height: height)
            moveTo(screenPoint)
            show()

        case .cursor:
            if !isVisible || !wasInCursorMode {
                // Snap to mouse position when first entering cursor mode
                let mouseLocation = NSEvent.mouseLocation
                cursorSnapPoint = mouseLocation
                moveTo(NSPoint(x: mouseLocation.x + 8, y: mouseLocation.y))
                show()
            }

        case .none:
            let workItem = DispatchWorkItem { [weak self] in
                self?.hide()
            }
            hideWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: workItem)
        }
    }

    func hide() {
        panel.orderOut(nil)
        isVisible = false
        cursorSnapPoint = nil
    }

    private func show() {
        if !isVisible {
            panel.orderFrontRegardless()
            isVisible = true
        }
    }

    private func moveTo(_ point: NSPoint) {
        guard let screen = NSScreen.main ?? NSScreen.screens.first else { return }
        let frame = screen.visibleFrame

        // Clamp to screen bounds
        let x = min(max(point.x, frame.minX), frame.maxX - panel.frame.width)
        let y = min(max(point.y, frame.minY), frame.maxY - panel.frame.height)

        panel.setFrameOrigin(NSPoint(x: x, y: y))
    }

    /// Convert AX coordinates (top-left origin) to AppKit coordinates (bottom-left origin)
    private func axToAppKit(axX: CGFloat, axY: CGFloat, height: CGFloat) -> NSPoint {
        guard let screen = NSScreen.screens.first else {
            return NSPoint(x: axX, y: axY)
        }
        let primaryHeight = screen.frame.height
        let dotSize: CGFloat = 17
        // Center dot vertically on the caret, accounting for dot's own size
        let caretCenterY = primaryHeight - axY - height / 2
        let nsY = caretCenterY - dotSize / 2
        return NSPoint(x: axX, y: nsY)
    }
}
