import Foundation

public enum UpdateStatus: Equatable {
    case idle
    case checking
    case upToDate(String)
    case updateAvailable(version: String, url: URL)
    case failed(String)
}

public final class UpdateCheckService: ObservableObject {
    public static let shared = UpdateCheckService()

    @Published public var status: UpdateStatus = .idle
    public let currentVersion = "v0.2"

    private init() {}

    public func checkForUpdates() {
        self.status = .checking

        guard let url = URL(string: "https://api.github.com/repos/viniroque3/use-token-bar/releases/latest") else {
            self.status = .failed("Invalid update URL")
            return
        }

        var request = URLRequest(url: url)
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        request.setValue("UseTokenBar-App", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 8.0

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                guard error == nil, let data = data else {
                    self.status = .failed("Network unavailable")
                    return
                }

                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let tagName = json["tag_name"] as? String {
                    let releaseURLStr = (json["html_url"] as? String) ?? "https://github.com/viniroque3/use-token-bar/releases/latest"
                    let releaseURL = URL(string: releaseURLStr) ?? URL(string: "https://github.com/viniroque3/use-token-bar/releases")!

                    let cleanRemote = tagName.trimmingCharacters(in: CharacterSet(charactersIn: "vV "))
                    let cleanLocal = self.currentVersion.trimmingCharacters(in: CharacterSet(charactersIn: "vV "))

                    if cleanRemote > cleanLocal {
                        self.status = .updateAvailable(version: tagName, url: releaseURL)
                    } else {
                        self.status = .upToDate(self.currentVersion)
                    }
                } else {
                    self.status = .failed("Could not check")
                }
            }
        }.resume()
    }
}
