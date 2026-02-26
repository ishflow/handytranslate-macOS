import AppKit

final class ClipboardManager {
    private var savedItems: [(type: NSPasteboard.PasteboardType, data: Data)] = []

    func save() {
        savedItems.removeAll()
        let pasteboard = NSPasteboard.general
        guard let items = pasteboard.pasteboardItems else { return }

        for item in items {
            for type in item.types {
                if let data = item.data(forType: type) {
                    savedItems.append((type: type, data: data))
                }
            }
        }
    }

    func restore() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        guard !savedItems.isEmpty else { return }

        let item = NSPasteboardItem()
        for saved in savedItems {
            item.setData(saved.data, forType: saved.type)
        }
        pasteboard.writeObjects([item])

        savedItems.removeAll()
    }

    static func readText() -> String? {
        NSPasteboard.general.string(forType: .string)
    }

    static func writeText(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }

    static func clear() {
        NSPasteboard.general.clearContents()
    }
}
