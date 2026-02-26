import AppKit
import Shared

final class FloatingDotView: NSView {
    private static let dotSize: CGFloat = 13
    private static let idleColor = NSColor(red: 1.0, green: 0.42, blue: 0.0, alpha: 1.0)   // #FF6B00
    private static let doneColor = NSColor(red: 0.133, green: 0.773, blue: 0.369, alpha: 1.0) // #22c55e
    private static let errorColor = NSColor(red: 0.937, green: 0.267, blue: 0.267, alpha: 1.0) // #ef4444
    private static let borderColor = NSColor.white

    var onClick: (() -> Void)?

    var state: TranslationState = .idle {
        didSet {
            needsDisplay = true
            updateAnimation()
        }
    }

    private var pulseTimer: Timer?

    override init(frame: NSRect) {
        super.init(frame: frame)
        wantsLayer = true
        addTrackingArea(NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
            owner: self,
            userInfo: nil
        ))
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: NSSize {
        NSSize(width: Self.dotSize + 4, height: Self.dotSize + 4)
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let dotRect = NSRect(
            x: (bounds.width - Self.dotSize) / 2,
            y: (bounds.height - Self.dotSize) / 2,
            width: Self.dotSize,
            height: Self.dotSize
        )

        let path = NSBezierPath(ovalIn: dotRect)

        // Fill color based on state
        let fillColor: NSColor
        switch state {
        case .idle, .loading:
            fillColor = Self.idleColor
        case .done:
            fillColor = Self.doneColor
        case .error:
            fillColor = Self.errorColor
        }

        fillColor.setFill()
        path.fill()

        // White border
        Self.borderColor.setStroke()
        path.lineWidth = 1.5
        path.stroke()
    }

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }

    override func mouseDown(with event: NSEvent) {
        onClick?()
    }

    override func mouseEntered(with event: NSEvent) {
        NSCursor.pointingHand.push()
    }

    override func mouseExited(with event: NSEvent) {
        NSCursor.pop()
    }

    private func updateAnimation() {
        pulseTimer?.invalidate()
        pulseTimer = nil
        layer?.opacity = 1.0

        if case .loading = state {
            startPulse()
        }
    }

    private func startPulse() {
        var fadingOut = true
        pulseTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self, let layer = self.layer else { return }
            if fadingOut {
                layer.opacity -= 0.03
                if layer.opacity <= 0.3 { fadingOut = false }
            } else {
                layer.opacity += 0.03
                if layer.opacity >= 1.0 { fadingOut = true }
            }
        }
    }

    deinit {
        pulseTimer?.invalidate()
    }
}
