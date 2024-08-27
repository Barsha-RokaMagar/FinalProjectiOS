import SwiftUI
import Firebase

struct PatientView: View {
    @State private var navigateToLogin = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome Users")
                    .font(.largeTitle)
                    .padding()
                
                Text("\"Remember to take care of yourself along the way\"")
                    .italic()
                    .padding(.bottom, 20)
                
                Image("patients")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .padding(.bottom, 20)
                
                Text("Select the specialist of your choice and proceed to schedule an appointment.")
                    .padding()
                    .multilineTextAlignment(.center)
                
                VStack {
                    HStack {
                        NavigationLink(destination: CardiologistView()) {
                            SpecialistButton(icon: "heart.fill", title: "Cardiologist")
                        }
                        NavigationLink(destination: DentistView()) {
                            SpecialistButton(icon: "bandage.fill", title: "Dentist")
                        }
                        NavigationLink(destination: PsychologistView()) {
                            SpecialistButton(icon: "person.2.fill", title: "Psychologist")
                        }
                    }
                    HStack {
                        NavigationLink(destination: DermatologistView()) {
                            SpecialistButton(icon: "pills.fill", title: "Dermatologist")
                        }
                        NavigationLink(destination: PediatricianView()) {
                            SpecialistButton(icon: "person.fill", title: "Pediatrician")
                        }
                        NavigationLink(destination: OpthalmologistView()) {
                            SpecialistButton(icon: "eye.fill", title: "Opthalmologist")
                        }
                    }
                    HStack {
                        NavigationLink(destination: NeurologistView()) {
                            SpecialistButton(icon: "brain.head.profile", title: "Neurologist")
                        }
                        NavigationLink(destination: GynecologistView()) {
                            SpecialistButton(icon: "staroflife.fill", title: "Gynecologist")
                        }
                    }
                    .padding(10)
                    
                    HStack {
                        NavigationLink(destination: PatientProfileView(patientId: Auth.auth().currentUser?.uid ?? "")) {
                            Text("Profile")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: 150, minHeight: 50)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        Spacer()

                        Button(action: logout) {
                            Text("Logout")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: 140, minHeight: 18)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    .padding(20)
                }
            }
            .background(
                NavigationLink(
                    destination: LoginView(isLoggedIn: .constant(false)),
                    isActive: $navigateToLogin,
                    label: { EmptyView() }
                )
            )
            .navigationTitle("Patient Dashboard")
        }
    }
    
    private func logout() {
        do {
            try Auth.auth().signOut()
            navigateToLogin = true
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError.localizedDescription)
        }
    }
}

struct SpecialistButton: View {
    var icon: String
    var title: String
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
            Text(title)
                .font(.subheadline)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 100)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct PatientView_Previews: PreviewProvider {
    static var previews: some View {
        PatientView()
    }
}
