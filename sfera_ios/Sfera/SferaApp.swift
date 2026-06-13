import SwiftUI

@main
struct SferaApp: App {
    @StateObject private var serverConfig = ServerConfig()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(serverConfig)
                .preferredColorScheme(.dark)
        }
    }
}
