import SwiftUI
import Firebase

@main
struct FinalPrjoectiOSApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
