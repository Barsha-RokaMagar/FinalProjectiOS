import SwiftUI
import FirebaseAuth

struct ResetpwView: View {
    @State private var email: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    var body: some View {
        VStack {
            Image(.resetpw)
                .resizable()
                .frame(width: 200, height: 200)
                .scaledToFit()
            Text("Reset Password")
                .font(.largeTitle)
                .padding()

            TextField("Email", text: $email)
                .padding()
                .border(Color.black)

            Button(action: resetPassword) {
                Text("Reset")
                .bold()
                .frame(width: 365 ,height: 50)
                .foregroundColor(.white)
                .background(Color.blue)
                .padding()
                .cornerRadius(20)
                .font(.title)
                .multilineTextAlignment(.center)
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Alert"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
        .padding()
        .navigationTitle("Reset Password")
    }

    private func resetPassword() {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                alertMessage = "Failed to send password reset email: \(error.localizedDescription)"
                showAlert = true
            } else {
                alertMessage = "Password reset email sent successfully."
                showAlert = true
            }
        }
    }
}

struct ResetpwView_Previews: PreviewProvider {
    static var previews: some View {
        ResetpwView()
    }
}
