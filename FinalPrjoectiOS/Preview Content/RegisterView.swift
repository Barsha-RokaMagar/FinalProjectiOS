import SwiftUI
import Firebase

struct RegisterView: View {
    @State private var name = ""
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var email = ""
    @State private var specialty = ""
    @State private var userType = "Patient"
    @State private var gender = "Male"
    @State private var showSpecialty = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var navigateToLogin = false
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @Binding var isLoggedIn: Bool

    var body: some View {
        NavigationStack {
            VStack {
                Image("usericon")
                    .resizable()
                    .frame(width: 100, height: 100)
                
                Text("Create New Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(.systemGreen))
                    .padding(.bottom, 30)
                
                TextField("Name", text: $name)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(5)
                    .padding(.bottom, 10)
                
                TextField("Username", text: $username)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(5)
                    .padding(.bottom, 10)
                
                Picker("Select the user type", selection: $userType) {
                    Text("Doctor").tag("Doctor")
                    Text("Patient").tag("Patient")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .onChange(of: userType) { value in
                    showSpecialty = value == "Doctor"
                }
                
                if showSpecialty {
                    TextField("Specialty", text: $specialty)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(5)
                        .padding(.bottom, 10)
                }
                
                Picker("Select your gender", selection: $gender) {
                    Text("Male").tag("Male")
                    Text("Female").tag("Female")
                    Text("Others").tag("Others")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                TextField("Email", text: $email)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(5)
                    .padding(.bottom, 10)
                
                PasswordField(placeholder: "Password", text: $password, showPassword: $showPassword)
                PasswordField(placeholder: "Confirm Password", text: $confirmPassword, showPassword: $showConfirmPassword)
                
                Button(action: signUp) {
                    Text("Sign Up")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .font(.title)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 35)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Alert"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }

                NavigationLink(
                    destination: LoginView(isLoggedIn: $isLoggedIn),
                    isActive: $navigateToLogin
                ) {
                    EmptyView()
                }

                Text("Already have an account?")
                    .padding(.top, 20)
                
                NavigationLink(destination: LoginView(isLoggedIn: $isLoggedIn)) {
                    Text("Login")
                        .foregroundColor(.black)
                }
            }
            .padding()
        }
    }
    
    private func signUp() {
        guard !name.isEmpty, !email.isEmpty, !username.isEmpty, !password.isEmpty, password == confirmPassword else {
            alertMessage = "Please fill all fields and ensure passwords match"
            showAlert = true
            return
        }
        
        if userType == "Doctor" && specialty.isEmpty {
            alertMessage = "Please enter your specialty"
            showAlert = true
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                alertMessage = "Authentication failed: \(error.localizedDescription)"
                showAlert = true
            } else {
                guard let uid = authResult?.user.uid else { return }
                
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = username
                changeRequest?.commitChanges { error in
                    if let error = error {
                        print("Error updating display name: \(error.localizedDescription)")
                    }
                }
                
                let userData: [String: Any] = [
                    "name": name,
                    "email": email,
                    "username": username,
                    "userType": userType,
                    "gender": gender,
                    "specialty": specialty,
                    "appointments": [String]()
                ]
                
                let ref = Database.database().reference()
                ref.child("users").child(uid).setValue(userData) { error, _ in
                    if let error = error {
                        alertMessage = "Error saving user data: \(error.localizedDescription)"
                        showAlert = true
                    } else {
                        alertMessage = "Sign Up Successful"
                        showAlert = true
                        isLoggedIn = true
                        print("Setting navigateToLogin to true")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            print("Navigating to login view")
                            navigateToLogin = true
                        }
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
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(5)
                    .multilineTextAlignment(.center)
            } else {
                SecureField(placeholder, text: $text)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(5)
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
    @State static var isLoggedIn = false

    static var previews: some View {
        RegisterView(isLoggedIn: $isLoggedIn)
    }
}
