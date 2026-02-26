import SwiftUI
import Shared

struct SettingsView: View {
    @ObservedObject var settings: AppSettings
    @State private var apiKeyInput: String = ""
    @State private var showSaved = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("HandyTranslate Settings")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                Text("OpenAI API Key")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                SecureField("sk-...", text: $apiKeyInput)
                    .textFieldStyle(.roundedBorder)

                HStack {
                    Button("Save") {
                        settings.apiKey = apiKeyInput
                        showSaved = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showSaved = false
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)

                    if showSaved {
                        Text("Saved!")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 4) {
                Text("Usage")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text("1. Click on any text input field")
                Text("2. Type your text (Turkish or English)")
                Text("3. Click the orange dot or press ⌘⇧T")
                Text("4. Text will be translated automatically")
            }
            .font(.caption)
            .foregroundColor(.secondary)

            Spacer()
        }
        .padding(20)
        .frame(width: 400, height: 200)
        .onAppear {
            apiKeyInput = settings.apiKey
        }
    }
}
