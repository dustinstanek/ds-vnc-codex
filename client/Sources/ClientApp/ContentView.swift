import SwiftUI

struct Host: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let address: String
}

struct ContentView: View {
    @EnvironmentObject var session: RemoteSession
    @State private var selectedHost: Host?

    var body: some View {
        Group {
            if session.connectionState == .connected {
                ScreenShareView()
            } else {
                VStack {
                    List(session.availableHosts, selection: $selectedHost) { host in
                        Text(host.name).tag(host as Host?)
                    }
                    .frame(minHeight: 200)

                    HStack {
                        Button("Connect") {
                            if let host = selectedHost {
                                session.connect(to: host)
                            }
                        }
                        .disabled(selectedHost == nil || session.isConnecting)

                        Text(session.statusMessage)
                            .foregroundColor(session.connectionState == .connected ? .green : .secondary)
                    }
                    .padding()
                }
            }
        }
        .frame(minWidth: 400, minHeight: 300)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(RemoteSession())
    }
}
