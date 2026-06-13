import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var serverConfig: ServerConfig
    @Environment(\.dismiss) private var dismiss
    @State private var urlText = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("http://212.220.113.9:10124", text: $urlText)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.URL)
                } header: {
                    Text("Адрес сервера")
                } footer: {
                    Text("Для iPhone используйте HTTP-порт 10124. Сервер должен быть запущен и порт открыт в файрволе.")
                }

                Section {
                    Button("Сохранить") {
                        var trimmed = urlText.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard trimmed.hasPrefix("http://") || trimmed.hasPrefix("https://") else { return }
                        while trimmed.hasSuffix("/") { trimmed.removeLast() }
                        serverConfig.serverURL = trimmed
                        dismiss()
                    }
                    .disabled(!isValidURL)

                    Button("Сбросить по умолчанию", role: .destructive) {
                        serverConfig.reset()
                        urlText = ServerConfig.defaultURL
                    }
                }
            }
            .navigationTitle("Сервер")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") { dismiss() }
                }
            }
            .onAppear {
                urlText = serverConfig.serverURL
            }
        }
    }

    private var isValidURL: Bool {
        let t = urlText.trimmingCharacters(in: .whitespacesAndNewlines)
        return t.hasPrefix("http://") || t.hasPrefix("https://")
    }
}
