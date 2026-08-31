import SwiftUI
import WidgetKit

@main
struct DUOTaskApp: App {
    @State private var loggedIn = SharedSession.token != nil
    @State private var user = SharedSession.user ?? "Luisa"

    var body: some Scene {
        WindowGroup {
            if loggedIn {
                DuoWebView(user: user) {
                    SharedSession.token = nil
                    SharedSession.user = nil
                    loggedIn = false
                }
            } else {
                LoginView { newUser in
                    user = newUser
                    loggedIn = true
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }
        }
    }
}
