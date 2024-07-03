import SwiftUI
import Firebase

@main
struct FinalProjectiOSApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
