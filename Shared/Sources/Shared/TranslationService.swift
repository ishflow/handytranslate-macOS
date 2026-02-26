import Foundation

public final class TranslationService: Sendable {
    private let client: OpenAIClient

    private static let systemPrompt = """
        You are a translator. If the text is in Turkish, translate to English. \
        If the text is in English, translate to Turkish. \
        Return ONLY the translated text, nothing else.
        """

    public init(apiKey: String) {
        self.client = OpenAIClient(apiKey: apiKey)
    }

    public func translate(_ text: String) async throws -> String {
        try await client.chatCompletion(
            systemPrompt: Self.systemPrompt,
            userMessage: text
        )
    }
}
