import Foundation
import Dispatch
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct HostAgentConfig {
    let hostID: String
    let brokerURL: URL
    let keyPath: String
}

final class RemoteManagementMonitor {
    private var timer: Timer?
    private let interval: TimeInterval = 60

    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            self.ensureRemoteManagementEnabled()
        }
        RunLoop.current.add(timer!, forMode: .default)
        ensureRemoteManagementEnabled()
    }

    private func ensureRemoteManagementEnabled() {
        let kickstart = "/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart"
        let process = Process()
        process.executableURL = URL(fileURLWithPath: kickstart)
        process.arguments = ["-activate", "-configure", "-access", "-on", "-clientopts", "-setreqperm", "-reqperm", "no"]
        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            NSLog("Failed to enable Remote Management: \(error)")
        }
    }
}

final class BrokerConnection {
    private let url: URL
    private let session: URLSession
    private var task: URLSessionWebSocketTask?

    init(url: URL) {
        self.url = url
        self.session = URLSession(configuration: .default)
    }

    func connect(hostID: String, keyPath: String) {
        task = session.webSocketTask(with: url)
        task?.resume()
        authenticate(hostID: hostID, keyPath: keyPath)
        receive()
    }

    private func authenticate(hostID: String, keyPath: String) {
        guard let sendData = buildAuthPayload(hostID: hostID, keyPath: keyPath) else {
            NSLog("Unable to read key at \(keyPath)")
            return
        }
        task?.send(.data(sendData)) { error in
            if let error = error {
                NSLog("Failed to send auth: \(error)")
            }
        }
    }

    private func receive() {
        task?.receive { [weak self] result in
            switch result {
            case .failure(let error):
                NSLog("WebSocket receive error: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    NSLog("Received string: \(text)")
                case .data(let data):
                    NSLog("Received \(data.count) bytes")
                @unknown default:
                    break
                }
            }
            self?.receive()
        }
    }
}

func buildAuthPayload(hostID: String, keyPath: String) -> Data? {
    guard let data = FileManager.default.contents(atPath: keyPath),
          let key = String(data: data, encoding: .utf8) else {
        return nil
    }
    let payload: [String: String] = [
        "host_id": hostID,
        "key": key.trimmingCharacters(in: .whitespacesAndNewlines)
    ]
    return try? JSONSerialization.data(withJSONObject: payload, options: [])
}

func parseArguments() -> HostAgentConfig? {
    var hostID: String?
    var brokerURL: URL?
    var keyPath: String?

    var iterator = CommandLine.arguments.dropFirst().makeIterator()
    while let arg = iterator.next() {
        switch arg {
        case "--host-id":
            hostID = iterator.next()
        case "--broker-url":
            if let urlString = iterator.next() {
                brokerURL = URL(string: urlString)
            }
        case "--key-path":
            keyPath = iterator.next()
        default:
            break
        }
    }

    let defaultKeyPath = FileManager.default
        .homeDirectoryForCurrentUser
        .appendingPathComponent(".ds-vnc/keys/host_key.pub")
        .path

    if let hostID = hostID, let brokerURL = brokerURL {
        return HostAgentConfig(hostID: hostID, brokerURL: brokerURL, keyPath: keyPath ?? defaultKeyPath)
    }

    print("Usage: HostAgent --host-id <ID> --broker-url <URL> [--key-path <PATH>]")
    return nil
}
