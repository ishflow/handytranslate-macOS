import AppKit
import Shared

@MainActor
final class TranslationCoordinator {
    private let settings: AppSettings
    private let clipboardManager = ClipboardManager()
    private var isTranslating = false

    var onStateChanged: ((TranslationState) -> Void)?

    init(settings: AppSettings) {
        self.settings = settings
    }

    func performTranslation() {
        guard !isTranslating else { return }
        guard settings.hasApiKey else {
            onStateChanged?(.error("No API key"))
            resetStateAfterDelay(seconds: 2)
            return
        }

        isTranslating = true
        onStateChanged?(.loading)

        // Save reference to the frontmost app before we do anything
        let frontApp = NSWorkspace.shared.frontmostApplication

        Task { @MainActor in
            defer {
                isTranslating = false
            }

            do {
                // Re-activate the previous frontmost app
                frontApp?.activate()
                try await Task.sleep(nanoseconds: 50_000_000) // 50ms

                // Save clipboard, then select all + copy
                clipboardManager.save()
                ClipboardManager.clear()

                KeyboardSimulator.selectAll()
                try await Task.sleep(nanoseconds: 80_000_000) // 80ms

                KeyboardSimulator.copy()
                try await Task.sleep(nanoseconds: 80_000_000) // 80ms

                // Read selected text
                guard let selectedText = ClipboardManager.readText(), !selectedText.isEmpty else {
                    clipboardManager.restore()
                    onStateChanged?(.error("No text"))
                    resetStateAfterDelay(seconds: 2)
                    return
                }

                // Restore original clipboard
                clipboardManager.restore()

                // Translate
                let service = TranslationService(apiKey: settings.apiKey)
                let translated = try await service.translate(selectedText)

                // Write translation to clipboard and paste
                clipboardManager.save()
                ClipboardManager.writeText(translated)
                try await Task.sleep(nanoseconds: 50_000_000) // 50ms

                KeyboardSimulator.selectAll()
                try await Task.sleep(nanoseconds: 50_000_000) // 50ms

                KeyboardSimulator.paste()
                try await Task.sleep(nanoseconds: 150_000_000) // 150ms

                // Restore original clipboard
                clipboardManager.restore()

                onStateChanged?(.done)
                resetStateAfterDelay(seconds: 1.5)

            } catch {
                onStateChanged?(.error(error.localizedDescription))
                resetStateAfterDelay(seconds: 2)
            }
        }
    }

    private func resetStateAfterDelay(seconds: Double) {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            onStateChanged?(.idle)
        }
    }
}
