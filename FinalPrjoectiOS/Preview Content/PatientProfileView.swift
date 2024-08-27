import SwiftUI
import Firebase
import FirebaseDatabase

struct PatientProfileView: View {
    @StateObject private var viewModel: PatientProfileViewModel
    @Environment(\.presentationMode) private var presentationMode

    init(patientId: String) {
        _viewModel = StateObject(wrappedValue: PatientProfileViewModel(patientId: patientId))
    }

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else {
                    Text(viewModel.patientName)
                        .font(.largeTitle)
                        .padding()

                    ScrollView {
                        LazyVStack {
                            if viewModel.appointments.isEmpty {
                                Text("No appointments available.")
                                    .padding()
                            } else {
                                ForEach(viewModel.appointments) { appointment in
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("Doctor: \(appointment.doctorName)")
                                            .font(.headline)
                                        Text("Date: \(appointment.date)")
                                            .font(.subheadline)
                                        Text("Time: \(appointment.time)")
                                            .font(.subheadline)
                                        Text("Status: \(appointment.status)")
                                            .font(.subheadline)
                                    }
                                    .padding()
                                }
                            }
                        }
                    }

                    if let errorMessage = viewModel.errorMessage {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                            .padding()
                    }
                }

                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Go Back")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
            .navigationTitle("Patient Profile")
        }
        .onAppear {
            viewModel.loadPatientData()
            viewModel.loadAppointments()
        }
    }
}

class PatientProfileViewModel: ObservableObject {
    @Published var appointments: [PatientAppointment] = []
    @Published var isLoading = true
    @Published var errorMessage: String?
    @Published var patientName: String = ""
    
    private var patientId: String
    private var ref = Database.database().reference()

    init(patientId: String) {
        self.patientId = patientId
    }
    
    func loadPatientData() {
        ref.child("users").child(patientId).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                if let data = snapshot.value as? [String: Any],
                   let name = data["name"] as? String {
                    self.patientName = name
                }
            }
            self.isLoading = false
        } withCancel: { error in
            self.errorMessage = "Error fetching patient data: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    func loadAppointments() {
        ref.child("appointments")
            .queryOrdered(byChild: "patientId")
            .queryEqual(toValue: patientId)
            .observe(.value) { snapshot in
                var appointments: [PatientAppointment] = []

                if snapshot.exists() {
                    for child in snapshot.children.allObjects as! [DataSnapshot] {
                        if let data = child.value as? [String: Any] {
                            let appointment = PatientAppointment(data: data)
                            appointments.append(appointment)
                        }
                    }
                    self.appointments = appointments
                }
                self.isLoading = false
            } withCancel: { error in
                self.errorMessage = "Error fetching appointments: \(error.localizedDescription)"
                self.isLoading = false
            }
    }
}

struct PatientAppointment: Identifiable {
    var id: String
    var doctorName: String
    var date: String
    var time: String
    var status: String

    init(data: [String: Any]) {
        self.id = UUID().uuidString

       
        let specialistKeys = ["cardiologist", "dentist", "dermatologist", "generalPractitioner", "orthopedic"]

       
        self.doctorName = specialistKeys.compactMap { data[$0] as? String }.first ?? "Unknown"

        self.date = data["date"] as? String ?? "Unknown"
        self.time = data["time"] as? String ?? "Unknown"
        self.status = data["status"] as? String ?? "Unknown"
    }
}

struct PatientProfileView_Previews: PreviewProvider {
    static var previews: some View {
        PatientProfileView(patientId: "examplePatientId")
    }
}
