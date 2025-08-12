import SwiftUI

struct PreferencesView: View {
    @AppStorage("publicKey") private var publicKey: String = ""
    @AppStorage("autoReconnect") private var autoReconnect: Bool = true
    @AppStorage("videoQuality") private var videoQuality: Double = 0.8

    var body: some View {
        Form {
            Section(header: Text("Security")) {
                TextField("SSH Public Key", text: $publicKey)
                Toggle("Reconnect Automatically", isOn: $autoReconnect)
            }
            Section(header: Text("Quality")) {
                Slider(value: $videoQuality, in: 0.1...1.0, step: 0.1) {
                    Text("Video Quality")
                }
            }
        }
        .padding(20)
        .frame(width: 400)
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
