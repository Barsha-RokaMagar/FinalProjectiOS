

import SwiftUI
import Firebase
import FirebaseFirestore

struct PatientProfileView: View {
    @State private var patientName: String = "Loading..."
    @State private var appointmentList: [PatientAppointment] = []
    @State private var isLoading: Bool = true

    var patientId: String
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 20) {
            Text("Patient Profile")
                .font(.title)
                .fontWeight(.bold)

            Text("Name: \(patientName)")
                .font(.body)

            List(appointmentList) { appointment in
                VStack(alignment: .leading) {
                    Text("Specialty: \(appointment.specialty)")
                    Text("Doctor: \(appointment.doctorName)")
                    Text("Date: \(appointment.date)")
                    Text("Time: \(appointment.time)")
                }
                .padding(.vertical, 4)
            }

            Button(action: goBack) {
                Text("Go Back")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.top, 24)
        }
        .padding()
        .onAppear {
            loadPatientDetails()
            loadAppointmentDetails()
        }
        .navigationBarTitle("Patient Profile", displayMode: .inline)
    }

    private func loadPatientDetails() {
        let db = Firestore.firestore()
        db.collection("users").document(patientId).getDocument { document, error in
            if let document = document, document.exists {
                if let data = document.data() {
                    patientName = data["name"] as? String ?? "Unknown"
                }
                isLoading = false
            } else {
                patientName = "Error loading patient details"
                print("Document does not exist")
                isLoading = false
            }
        }
    }

    private func loadAppointmentDetails() {
        let db = Firestore.firestore()
        db.collection("appointments")
            .whereField("patientId", isEqualTo: patientId)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    var appointments: [PatientAppointment] = []
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        if let doctorName = data["doctorName"] as? String,
                           let date = data["date"] as? String,
                           let time = data["time"] as? String,
                           let specialty = data["specialty"] as? String {
                            let appointment = PatientAppointment(
                                id: document.documentID,
                                doctorName: doctorName,
                                date: date,
                                time: time,
                                specialty: specialty
                            )
                            appointments.append(appointment)
                        }
                    }
                    appointmentList = appointments
                }
            }
    }

    private func goBack() {
        presentationMode.wrappedValue.dismiss()
    }
}

extension PatientProfileView {
    struct PatientAppointment: Identifiable {
        var id: String
        var doctorName: String
        var date: String
        var time: String
        var specialty: String
    }
}

struct PatientProfileView_Previews: PreviewProvider {
    static var previews: some View {
        PatientProfileView(patientId: "examplePatientId")
    }
}
