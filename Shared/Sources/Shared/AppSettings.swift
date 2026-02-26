import Foundation
import Combine

public final class AppSettings: ObservableObject {
    private static let appGroupID = "group.com.handytranslate"
    private static let apiKeyKey = "apiKey"

    @Published public var apiKey: String {
        didSet {
            // Save to both Keychain and App Group UserDefaults
            if apiKey.isEmpty {
                _ = KeychainHelper.delete()
            } else {
                _ = KeychainHelper.save(apiKey: apiKey)
            }
            UserDefaults(suiteName: Self.appGroupID)?.set(apiKey, forKey: Self.apiKeyKey)
        }
    }

    @Published public var isFloatingButtonVisible: Bool = true

    public var hasApiKey: Bool {
        !apiKey.isEmpty
    }

    public init() {
        // Try App Group UserDefaults first (shared with extension), then Keychain
        if let shared = UserDefaults(suiteName: Self.appGroupID)?.string(forKey: Self.apiKeyKey), !shared.isEmpty {
            self.apiKey = shared
        } else {
            self.apiKey = KeychainHelper.load() ?? ""
        }
    }

    /// Load API key from App Group (for use in extensions)
    public static func loadApiKeyFromAppGroup() -> String? {
        UserDefaults(suiteName: appGroupID)?.string(forKey: apiKeyKey)
    }
}
