import SwiftUI

@main
struct LibreWidgetApp: App {

    init() {
        if appConfiguration.connected != .connected {
            appConfiguration.connected = .disconnected
        }
    }

    var body: some Scene {
        WindowGroup {
            LibreWidgetSetupView()
        }
    }
}
