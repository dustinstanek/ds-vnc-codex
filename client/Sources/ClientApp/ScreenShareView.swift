import SwiftUI
import AVFoundation

/// Placeholder view that would host the screen sharing content.
struct ScreenShareView: View {
    @EnvironmentObject var session: RemoteSession

    var body: some View {
        Rectangle()
            .foregroundColor(.black)
            .overlay(Text("Remote desktop would appear here")
                .foregroundColor(.white))
    }
}
