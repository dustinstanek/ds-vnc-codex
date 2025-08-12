import Foundation

/// Represents a remote access session brokered through a server.
@MainActor
final class RemoteSession: ObservableObject {
    enum State {
        case idle
        case connecting
        case connected
        case failed(Error)
    }

    @Published var availableHosts: [Host] = [
        Host(name: "Office Mac", address: "mac.example.com"),
        Host(name: "Home iMac", address: "imac.example.com")
    ]

    @Published private(set) var connectionState: State = .idle

    var isConnecting: Bool {
        if case .connecting = connectionState { return true }
        return false
    }

    var statusMessage: String {
        switch connectionState {
        case .idle: return "Not Connected"
        case .connecting: return "Connecting..."
        case .connected: return "Connected"
        case .failed(let err): return "Failed: \(err.localizedDescription)"
        }
    }

    private let keysDirectory = FileManager.default
        .homeDirectoryForCurrentUser
        .appendingPathComponent(".ds-vnc/keys")

    private func loadKey(named name: String) throws -> String {
        let url = keysDirectory.appendingPathComponent(name)
        return try String(contentsOf: url)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Authenticate with the broker and establish a WebRTC/SSH tunnel.
    func connect(to host: Host) {
        connectionState = .connecting
        Task {
            do {
                try await authenticate()
                try await establishTunnel(to: host)
                await MainActor.run { self.connectionState = .connected }
            } catch {
                await MainActor.run { self.connectionState = .failed(error) }
            }
        }
    }

    private func authenticate() async throws {
        let clientKey = try loadKey(named: "client_key")
        // TODO: Send `clientKey` to the broker as part of authentication.
        try await Task.sleep(nanoseconds: 500_000_000)
    }

    private func establishTunnel(to host: Host) async throws {
        let expectedHostKey = try loadKey(named: "host_key.pub")
        // TODO: Retrieve `actualHostKey` from the host during tunnel setup.
        let actualHostKey = expectedHostKey // Placeholder until handshake implemented.
        guard actualHostKey == expectedHostKey else {
            throw NSError(domain: "RemoteSession", code: 1, userInfo: [NSLocalizedDescriptionKey: "Host identity mismatch"])
        }
        try await Task.sleep(nanoseconds: 500_000_000)
    }
}
