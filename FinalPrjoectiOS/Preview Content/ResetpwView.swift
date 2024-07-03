import SwiftUI
import FirebaseAuth

struct ResetpwView: View {
    @State private var email: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    var body: some View {
        NavigationStack {
            VStack {
                Image(.resetpw) 
                    .resizable()
                    .frame(width: 100, height: 100)
                    .scaledToFit()
                Text("Reset Password")
                    .bold()
                    .font(.custom("AmericanTypewriter", fixedSize: 25))
                    .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.2))
                
                TextField("Email", text: $email)
                    .padding()
                    .border(Color.black)
                    .multilineTextAlignment(.center)
                    .padding()
                
                SecureField("New Password", text: $newPassword)
                    .padding()
                    .border(Color.black)
                    .multilineTextAlignment(.center)
                    .padding()
                
                SecureField("Confirm Password", text: $confirmPassword)
                    .padding()
                    .border(Color.black)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Button(action: resetPassword) {
                    Text("Save")
                        .bold()
                        .frame(width: 200,height: 50)
                        .foregroundColor(.white)
                        .background(Color.purple)
                        .padding()
                        .cornerRadius(10)
                        .font(.title)
                        .multilineTextAlignment(.center)
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Message"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                
                NavigationLink(destination: LoginView(isLoggedIn: .constant(false))) {
                    Text("Back to Login")
                        .foregroundColor(.blue)
                        .padding()
                }
            }
            .padding()
        }
    }

    private func resetPassword() {
        
        if newPassword == confirmPassword {
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error = error {
                    alertMessage = error.localizedDescription
                } else {
                    alertMessage = "Reset password email sent."
                }
                showAlert = true
            }
        } else {
            alertMessage = "Passwords do not match."
            showAlert = true
        }
    }
}

#Preview {
    ResetpwView()
}
