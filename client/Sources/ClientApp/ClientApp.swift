import SwiftUI

@main
struct ClientApp: App {
    @StateObject private var session = RemoteSession()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(session)
        }
        Settings {
            PreferencesView()
                .environmentObject(session)
        }
    }
}
