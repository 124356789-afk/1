import Foundation

final class ServerConfig: ObservableObject {
    private static let key = "sfera_server_url"
    static let defaultURL = "http://212.220.113.9:10124"

    @Published var serverURL: String {
        didSet {
            UserDefaults.standard.set(serverURL, forKey: Self.key)
        }
    }

    init() {
        serverURL = UserDefaults.standard.string(forKey: Self.key) ?? Self.defaultURL
    }

    func reset() {
        serverURL = Self.defaultURL
    }
}
