import SwiftUI
import Firebase

struct registerView: View {
    @State private var name = ""
    @State private var username = ""
    @State private var password = ""
    @State private var email = ""
    @State private var specialty = ""
    @State private var userType = "Doctor"
    @State private var gender = "Male"
    @State private var showSpecialty = true
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Binding var isLoggedIn: Bool

    var body: some View {
        NavigationStack {
            VStack {
                Image(.usericon) // Ensure this image exists in your assets
                    .resizable()
                    .frame(width: 100, height: 100)
                
                Text("Create New Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(.green)) // Ensure you have this color defined
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
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(5)
                    .padding(.bottom, 10)
                
                Button(action: signUp) {
                    Text("SignUp")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
                .padding(.top, 35)
                
                NavigationLink(destination: LoginView(isLoggedIn: $isLoggedIn)) {
                    Text("Already have an account? Login")
                        .foregroundColor(.black)
                        .padding(.top, 20)
                }
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Alert"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func signUp() {
        guard !name.isEmpty, !email.isEmpty, !username.isEmpty, !password.isEmpty else {
            alertMessage = "Please fill all fields"
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
                let user = [
                    "name": name,
                    "email": email,
                    "username": username,
                    "password": password,
                    "userType": userType,
                    "gender": gender,
                    "specialty": specialty,
                    "appointments": [String]()
                ] as [String : Any]
                
                Database.database().reference().child("users").child(uid).setValue(user) { error, _ in
                    if let error = error {
                        alertMessage = "User registration failed: \(error.localizedDescription)"
                        showAlert = true
                    } else {
                        alertMessage = "User registered successfully"
                        showAlert = true
                        isLoggedIn = true // Update this after successful registration
                    }
                }
            }
        }
    }
}

struct registerView_Previews: PreviewProvider {
    @State static var isLoggedIn = false
    static var previews: some View {
        registerView(isLoggedIn: $isLoggedIn)
    }
}
