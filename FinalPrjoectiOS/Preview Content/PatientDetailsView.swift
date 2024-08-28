import SwiftUI
import Firebase
import FirebaseDatabase

struct PatientDetailsView: View {
    @State private var patientName: String = "Loading..."
    @State private var appointmentDate: String = "Loading..."
    @State private var appointmentTime: String = "Loading..."
    @State private var isLoading: Bool = true
    @State private var showAlert = false
    @State private var alertMessage = ""
    var patientId: String
    var appointmentId: String

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 20) {
            Text("Patient Details")
                .font(.title)
                .fontWeight(.bold)

            Text("Patient Name: \(patientName)")
                .font(.body)
            
            Text("Appointment Date: \(appointmentDate)")
                .font(.body)
            
            Text("Appointment Time: \(appointmentTime)")
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
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Go Back")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(10)
        } .alert(isPresented: $showAlert) {
            Alert(title: Text("Message"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .padding()
        .onAppear {
            loadPatientDetails()
        }
        .navigationBarTitle("Patient Details", displayMode: .inline)
    }

    private func loadPatientDetails() {
        let ref = Database.database().reference()
        
       
        ref.child("appointments").child(appointmentId).observeSingleEvent(of: .value) { snapshot in
            print("Appointment snapshot: \(snapshot.value ?? "No data")")
            if let data = snapshot.value as? [String: Any] {
                self.appointmentDate = data["date"] as? String ?? "Unknown"
                self.appointmentTime = data["time"] as? String ?? "Unknown"
                
               
                self.patientName = data["patientName"] as? String ?? "Unknown"
                self.isLoading = false
            } else {
                self.appointmentDate = "No data"
                self.appointmentTime = "No data"
                self.patientName = "No data"
                self.isLoading = false
            }
        } withCancel: { error in
            print("Error fetching appointment document: \(error.localizedDescription)")
            self.appointmentDate = "Error"
            self.appointmentTime = "Error"
            self.patientName = "Error"
            self.isLoading = false
        }
    }
    private func confirmAppointment() {
           let ref = Database.database().reference().child("appointments").child(appointmentId)
           
           ref.updateChildValues([
               "status": "Confirmed",
               "confirmationMessage": "Your appointment has been confirmed."
           ]) { error, _ in
               if let error = error {
                   print("Error updating appointment: \(error.localizedDescription)")
               } else {
                   updatePatientProfile(status: "Appointment Confirmed", message: "Your appointment has been confirmed.")
                   self.alertMessage = "Confirmed"
                   self.showAlert = true
               }
           }
       }
   

    private func cancelAppointment() {
        let ref = Database.database().reference().child("appointments").child(appointmentId)
        
        ref.removeValue { error, _ in
            if let error = error {
                print("Error removing appointment: \(error.localizedDescription)")
            } else {
                updatePatientProfile(status: "Appointment Cancelled", message: "Your appointment has been cancelled.")
                self.alertMessage = "Cancelled"
                self.showAlert = true
            }
        }
    }

    private func updatePatientProfile(status: String, message: String) {
        let ref = Database.database().reference().child("patients").child(patientId).child("appointments").child(appointmentId)
        
        ref.updateChildValues([
            "status": status,
            "confirmationMessage": message
        ]) { error, _ in
            if let error = error {
                print("Error updating patient profile: \(error.localizedDescription)")
            }
        }
    }
}

struct PatientDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        PatientDetailsView(patientId: "OkoWWYQgufcarLhxXtzGEgG2v1D3", appointmentId: "-O3hU5B_2Sywb10_SoIQ")
    }
}
