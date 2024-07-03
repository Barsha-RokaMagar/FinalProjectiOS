import SwiftUI
import Firebase

struct RegisterView: View {
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var usertype: String = "Patient"
    @State private var gender: String = "Male"
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var navigateToLogin: Bool = false
    @State private var showPassword: Bool = false
    @State private var showConfirmPassword: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                Image("usericon")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .scaledToFit()
                Text("Create New Account")
                    .bold()
                    .font(.custom("AmericanTypewriter", fixedSize: 25))
                TextField("Username", text: $username)
                    .padding()
                    .border(Color.black)
                    .multilineTextAlignment(.center)

                HStack {
                    Text("Select Usertype:")
                    Picker("Select user type", selection: $usertype) {
                        Text("Doctor").tag("Doctor")
                        Text("Patient").tag("Patient")
                    }.pickerStyle(SegmentedPickerStyle())
                }.padding()
                
                HStack {
                    Text("Select Gender:")
                    Picker("Select gender", selection: $gender) {
                        Text("Male").tag("Male")
                        Text("Female").tag("Female")
                        Text("Others").tag("Others")
                    }.pickerStyle(SegmentedPickerStyle())
                }.padding()
                
                TextField("Email", text: $email)
                    .padding()
                    .border(Color.black)
                    .multilineTextAlignment(.center)
                
                PasswordField(placeholder: "Password", text: $password, showPassword: $showPassword)
                PasswordField(placeholder: "Confirm Password", text: $confirmPassword, showPassword: $showConfirmPassword)
                
                Button(action: {
                    if validateFields() {
                        signUp()
                    }
                }) {
                    Text("Sign Up")
                        .bold()
                        .frame(width: 300, height: 50)
                        .foregroundColor(.white)
                        .background(Color.purple)
                        .padding()
                        .cornerRadius(20)
                        .font(.title)
                        .multilineTextAlignment(.center)
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text(alertMessage))
                }

                HStack {
                    Text("Already have an account?")
                    NavigationLink(destination: LoginView(isLoggedIn: .constant(false))) {
                        Text("Login").foregroundColor(.blue)
                    }
                }
                .padding()
                
                NavigationLink(destination: LoginView(isLoggedIn: .constant(false)), isActive: $navigateToLogin) {
                    EmptyView()
                }
            }
            .padding()
        }
    }
    
    private func validateFields() -> Bool {
        guard !username.isEmpty, !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            alertMessage = "Please fill in all fields."
            showAlert = true
            return false
        }
        
        guard password == confirmPassword else {
            alertMessage = "Passwords do not match."
            showAlert = true
            return false
        }
        
        return true
    }
    
    private func signUp() {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.alertMessage = error.localizedDescription
                self.showAlert = true
            } else {
                guard let user = authResult?.user else {
                    self.alertMessage = "User creation failed."
                    self.showAlert = true
                    return
                }
                
                let userData: [String: Any] = [
                    "username": self.username,
                    "email": self.email,
                    "usertype": self.usertype,
                    "gender": self.gender
                ]
                
                let ref = Database.database().reference()
                ref.child("users").child(username).setValue(userData) { error, _ in
                    if let error = error {
                        self.alertMessage = "Error saving user data: \(error.localizedDescription)"
                        self.showAlert = true
                    } else {
                        self.alertMessage = "Sign Up Successful"
                        self.showAlert = true
                        self.navigateToLogin = true
                    }
                }
            }
        }
    }
}

struct PasswordField: View {
    var placeholder: String
    @Binding var text: String
    @Binding var showPassword: Bool
    
    var body: some View {
        ZStack {
            if showPassword {
                TextField(placeholder, text: $text)
                    .padding()
                    .border(Color.black)
                    .multilineTextAlignment(.center)
            } else {
                SecureField(placeholder, text: $text)
                    .padding()
                    .border(Color.black)
                    .multilineTextAlignment(.center)
            }
            HStack {
                Spacer()
                Button(action: { showPassword.toggle() }) {
                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.gray)
                        .padding()
                }
            }
        }
    
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
