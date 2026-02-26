import SwiftUI

@main
struct HandyTranslateMacApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // No visible window — app lives in menu bar + floating panel
        Settings {
            EmptyView()
        }
    }
}
