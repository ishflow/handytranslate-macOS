import Foundation

public enum TranslationState: Equatable {
    case idle
    case loading
    case done
    case error(String)
}
