import SwiftUI
import Firebase

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var usertype: String = "Patient"
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var navigateToView: Bool = false
    @State private var navigateToResetPassword: Bool = false
    @State private var destinationView: AnyView? = nil
    @Binding var isLoggedIn: Bool

    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome Back")
                    .bold()
                    .font(.custom("AmericanTypewriter", fixedSize: 36))
                    .padding()

                Image(.welcome)
                    .resizable()
                    .scaledToFit()
                    .padding()

                Text("LOGIN")
                    .bold()
                    .font(.title)

                TextField("Email", text: $email)
                    .padding()
                    .border(Color.black)

                SecureField("Password", text: $password)
                    .padding()
                    .border(Color.black)

                HStack {
                    Text("Select Usertype:")
                    Picker("Select user type", selection: $usertype) {
                        Text("Doctor").tag("Doctor")
                        Text("Patient").tag("Patient")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                }

                Button(action: login) {
                    Text("Login")
                        .bold()
                        .frame(width: 350, height: 50)
                        .foregroundColor(.white)
                        .background(Color.purple)
                        .padding()
                        .cornerRadius(25.0)
                        .font(.title)
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }

                HStack {
                    Text("New user?")
                    NavigationLink(destination: registerView(isLoggedIn: $isLoggedIn)) {
                        Text("Sign Up").foregroundColor(.blue)
                    }

                    Button(action: {
                        navigateToResetPassword = true
                    }) {
                        Text("Forgot Password")
                            .foregroundColor(.blue)
                    }
                    .padding()
                }

               
                NavigationLink(
                    destination: destinationView,
                    isActive: $navigateToView
                ) {
                    EmptyView()
                }

                NavigationLink(
                    destination: ResetpwView(),
                    isActive: $navigateToResetPassword
                ) {
                    EmptyView()
                }
            }
            .padding()
            .navigationTitle("")
        }
    }

    private func login() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                alertMessage = error.localizedDescription
                showAlert = true
            } else {
                if usertype == "Doctor" {
                    destinationView = AnyView(DoctorView())
                } else {
                    destinationView = AnyView(PatientView())
                }
                navigateToView = true
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    @State static var isLoggedIn = false
    static var previews: some View {
        LoginView(isLoggedIn: $isLoggedIn)
    }
}
