import Foundation
import Dispatch

let signalSource = DispatchSource.makeSignalSource(signal: SIGTERM, queue: .main)
signal(SIGTERM, SIG_IGN)
signalSource.setEventHandler {
    exit(0)
}
signalSource.resume()

if let config = parseArguments() {
    let monitor = RemoteManagementMonitor()
    monitor.start()

    let broker = BrokerConnection(url: config.brokerURL)
    broker.connect(hostID: config.hostID, keyPath: config.keyPath)

    RunLoop.current.run()
}
