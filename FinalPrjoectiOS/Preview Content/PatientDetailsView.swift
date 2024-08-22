import SwiftUI
import Firebase
import FirebaseFirestore



struct PatientDetailsView: View {
    @State private var patientName: String = "Loading..."
    @State private var patientEmail: String = "Loading..."
    @State private var appointmentStatus: String = "Pending"
    @State private var isLoading: Bool = true

    var patientId: String
    var appointmentId: String

    var body: some View {
        VStack(spacing: 20) {
            Text("Patient Details")
                .font(.title)
                .fontWeight(.bold)

            Text("Name: \(patientName)")
                .font(.body)

            Text("Email: \(patientEmail)")
                .font(.body)

            Text("Appointment Status: \(appointmentStatus)")
                .font(.body)

            VStack {
                Button(action: confirmAppointment) {
                    Text("Confirm Appointment")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(10)
                
                Button(action: cancelAppointment) {
                    Text("Cancel Appointment")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(10)
            }
            .padding(.top, 25)

            Button(action: {
                
            }) {
                Text("Go Back")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(10)
        }
        .padding()
        .onAppear {
            loadPatientDetails()
        }
        .navigationBarTitle("Patient Details", displayMode: .inline)
    }

    private func loadPatientDetails() {
        let db = Firestore.firestore()
        db.collection("users").document(patientId).getDocument { document, error in
            if let document = document, document.exists {
                if let data = document.data() {
                    patientName = data["name"] as? String ?? "Unknown"
                    patientEmail = data["email"] as? String ?? "Unknown"
                    isLoading = false
                } else {
                    patientName = "No data"
                    patientEmail = "No data"
                }
            } else {
                patientName = "Error"
                patientEmail = "Error"
                print("Document does not exist")
            }
        }
    }

    private func confirmAppointment() {
        let db = Firestore.firestore()
        let appointmentRef = db.collection("appointments").document(appointmentId)
        
        appointmentRef.updateData([
            "status": "Confirmed",
            "confirmationMessage": "Your appointment has been confirmed."
        ]) { error in
            if let error = error {
                print("Error updating appointment: \(error)")
            } else {
                updatePatientProfile(status: "Appointment Confirmed", message: "Your appointment has been confirmed.")
            }
        }
    }

    private func cancelAppointment() {
        let db = Firestore.firestore()
        let appointmentRef = db.collection("appointments").document(appointmentId)
        
        appointmentRef.delete() { error in
            if let error = error {
                print("Error removing appointment: \(error)")
            } else {
                updatePatientProfile(status: "Appointment Cancelled", message: "Your appointment has been cancelled.")
            }
        }
    }

    private func updatePatientProfile(status: String, message: String) {
        let db = Firestore.firestore()
        let appointmentRef = db.collection("appointments").document(appointmentId)
        let patientProfileRef = db.collection("patients").document(patientId).collection("appointments").document(appointmentId)
        
        appointmentRef.updateData([
            "status": status,
            "confirmationMessage": message
        ]) { error in
            if let error = error {
                print("Error updating appointment profile: \(error)")
            }
        }
        
        patientProfileRef.updateData([
            "status": status,
            "confirmationMessage": message
        ]) { error in
            if let error = error {
                print("Error updating patient profile: \(error)")
            }
        }
    }
}

struct PatientDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        PatientDetailsView(patientId: "examplePatientId", appointmentId: "exampleAppointmentId")
    }
}
