import SwiftUI

struct ContentView: View {
    @State private var showSplashScreen = true
    @State private var isLoggedIn = false

    var body: some View {
        ZStack {
            if isLoggedIn {
                NavigationView {
                    if isLoggedIn {
                        Text("User is logged in") 
                    } else {
                        LoginView(isLoggedIn: $isLoggedIn)
                    }
                }
            } else {
                if showSplashScreen {
                    SplashScreenView()
                        .transition(.opacity)
                } else {
                    LoginView(isLoggedIn: $isLoggedIn)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    showSplashScreen = false
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
