import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var serverConfig: ServerConfig
    @StateObject private var webViewStore = WebViewStore()
    @State private var isLoading = false
    @State private var canGoBack = false
    @State private var showSettings = false
    @State private var loadError = false

    private var currentURL: URL {
        URL(string: serverConfig.serverURL.trimmingCharacters(in: .whitespacesAndNewlines))
            ?? URL(string: ServerConfig.defaultURL)!
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.12, green: 0.12, blue: 0.13).ignoresSafeArea()

                if loadError {
                    errorView
                } else if let url = URL(string: serverConfig.serverURL) {
                    WebView(url: url, isLoading: $isLoading, canGoBack: $canGoBack, webViewStore: webViewStore)
                        .ignoresSafeArea(edges: .bottom)
                } else {
                    errorView
                }

                if isLoading {
                    ProgressView()
                        .tint(Color(red: 0.35, green: 0.40, blue: 0.95))
                        .scaleEffect(1.2)
                }
            }
            .navigationTitle("Sfera")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(red: 0.17, green: 0.18, blue: 0.20), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    if canGoBack {
                        Button {
                            webViewStore.goBack()
                        } label: {
                            Image(systemName: "chevron.left")
                        }
                    }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        webViewStore.reload()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .environmentObject(serverConfig)
            }
        }
    }

    private var errorView: some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("Не удалось открыть Sfera")
                .font(.headline)
            Text("Проверьте адрес сервера и интернет")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("Настройки сервера") { showSettings = true }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 0.35, green: 0.40, blue: 0.95))
        }
        .padding()
    }
}
